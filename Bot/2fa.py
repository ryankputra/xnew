import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, MessageHandler, filters, CallbackQueryHandler
import pyotp

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Tempat untuk menyimpan secret key per user
user_secrets = {}
# Tempat untuk menyimpan ID pengguna yang pernah berinteraksi dengan bot
active_users = set()

# ID admin bot (admin Anda sendiri)
ADMIN_ID = 6583386476  # ID Admin yang kamu berikan

# Fungsi untuk mengirim OTP berdasarkan secret 2FA yang dikirim pengguna
async def generate_otp(update: Update, context):
    user = update.message.from_user
    secret = update.message.text.strip()  # Mengambil pesan dari pengguna sebagai secret

    # Periksa apakah pesan berisi secret yang valid (cukup panjang dan sesuai format)
    if len(secret) > 10:
        user_secrets[user.id] = secret  # Menyimpan secret untuk pengguna ini
        totp = pyotp.TOTP(secret)  # Menggunakan secret untuk menghasilkan OTP
        otp = totp.now()  # Mengambil OTP aktif saat ini

        # Menyimpan pengguna yang baru saja berinteraksi dengan bot
        active_users.add(user.id)

        # Membuat tombol inline yang memungkinkan pengguna menyalin OTP
        keyboard = [
            [InlineKeyboardButton("Copy OTP", callback_data=str(otp))]  # Mengubah OTP menjadi string
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)

        # Mengirim OTP dalam format monospace dan menambahkan tombol inline
        await update.message.reply_text(f'Your current OTP is:\n`{otp}`', parse_mode='Markdown', reply_markup=reply_markup)
        logger.info(f"Generated OTP for {user.username}: {otp}")
    else:
        await update.message.reply_text('Please send a valid 2FA secret.')

# Fungsi untuk menangani tombol inline
async def button(update: Update, context):
    query = update.callback_query
    await query.answer()  # Menanggapi klik tombol
    otp = query.data  # Mengambil OTP dari callback data
    await query.edit_message_text(text=f'You copied the OTP: `{otp}`', parse_mode='Markdown')

# Fungsi untuk menangani pesan dari admin
async def handle_admin_message(update: Update, context):
    user = update.message.from_user
    # Periksa apakah pengirim pesan adalah admin
    if user.id == ADMIN_ID:
        message_text = update.message.text.strip().replace('/sendall ', '')  # Mengambil pesan dari admin tanpa /sendall

        # Mengirim pesan ke semua pengguna yang pernah berinteraksi dengan bot
        for user_id in active_users:
            try:
                await context.bot.send_message(chat_id=user_id, text=message_text)  # Kirim pesan tanpa "Admin says"
            except Exception as e:
                logger.error(f"Failed to send message to user {user_id}: {e}")

        await update.message.reply_text("Message has been sent to all users.")
    else:
        # Jika bukan admin, memberi tahu pengguna bahwa hanya admin yang bisa mengirim pesan
        await update.message.reply_text("Only admin can send messages to this bot.")

# Fungsi untuk menangani pesan dari pengguna biasa (generate OTP)
async def handle_user_message(update: Update, context):
    await generate_otp(update, context)

# Main function untuk mengatur bot
def main():
    application = ApplicationBuilder().token('6855227665:AAGHRdC4RXnwuPWKODO_49yEl8YQmQ7BzSg').build()

    # Handler untuk pesan dari admin, hanya menerima perintah '/sendall'
    application.add_handler(MessageHandler(filters.TEXT & filters.Regex('^/sendall') & filters.User(user_id=ADMIN_ID), handle_admin_message))

    # Handler untuk pesan dari pengguna biasa (generate OTP)
    application.add_handler(MessageHandler(filters.TEXT & ~filters.Regex('^/sendall'), handle_user_message))

    # Menambahkan handler untuk menangani klik tombol inline
    application.add_handler(CallbackQueryHandler(button))

    # Mulai polling untuk menjaga bot tetap berjalan
    application.run_polling()

if __name__ == '__main__':
    main()
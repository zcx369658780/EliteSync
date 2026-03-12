import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from app.core.config import settings


class AESCipher:
    def __init__(self, key: str):
        self._key = key.encode("utf-8")

    def encrypt(self, text: str) -> str:
        aes = AESGCM(self._key)
        nonce = os.urandom(12)
        ciphertext = aes.encrypt(nonce, text.encode("utf-8"), None)
        return (nonce + ciphertext).hex()

    def decrypt(self, payload_hex: str) -> str:
        raw = bytes.fromhex(payload_hex)
        nonce, ciphertext = raw[:12], raw[12:]
        aes = AESGCM(self._key)
        return aes.decrypt(nonce, ciphertext, None).decode("utf-8")


cipher = AESCipher(settings.aes_key)

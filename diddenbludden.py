# // Diddenbludden tool for token decryption
# // my first python script :3

from win32crypt import CryptUnprotectData
from Crypto.Cipher import AES
import base64
import sys
import os

# // decrypts the token, reminder that token and key params should come already base64-decoded + splitted
def decryptToken(token:str, key:str) -> str:
	return AES.new(CryptUnprotectData(key, None, None, None, 0)[1], AES.MODE_GCM, token[3:15]).decrypt(token[15:])[:-16].decode()

# // decodes the token and key with base64, and splits them in order to be ready to get decrypted
def decodeToken(token:str, key:str) -> str:
	return decryptToken(base64.b64decode(token.split('dQw4w9WgXcQ:')[1]), base64.b64decode(key)[5:])

# // run the script
if __name__ == '__main__':
	didden_folder = sys.argv[1]

	# print('im sucking cock rn')

	with open(os.path.join(os.path.dirname(didden_folder), 'didden_temp_1.didden'), 'r', encoding = 'utf-8') as f:
		data = [line.strip() for line in f.readlines() if line.strip()]

		with open(os.path.join(os.path.dirname(didden_folder), 'didden_temp_2.didden'), 'w', encoding = 'utf-8') as f2:
			f2.write(decodeToken(data[0], data[1]))
require 'openssl'

class String
  def alt_encrypt(key = "x"*24)
    cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').encrypt
    # cipher.key = Digest::SHA1.hexdigest key
    cipher.key = key
    s = cipher.update(self) + cipher.final

    s.unpack('H*')[0].upcase
  end

  def alt_decrypt(key = "x"*24)
    cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').decrypt
    # cipher.key = Digest::SHA1.hexdigest key
    cipher.key = key
    s = [self].pack("H*").unpack("C*").pack("c*")

    cipher.update(s) + cipher.final
  end
end
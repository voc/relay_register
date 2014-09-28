class RelayRegister
  class AES

    CIPHER = 'aes-256-cbc'

    # Decrypt given base64 encoded data stream
    #
    # @param data [String] base64 encoded data
    # @param password [String] password
    # @param iv [String] initialization vector used for encryption
    # @return [String] plain text data
    def self.decrypt(data, password, iv)
      secretdata = Base64::decode64(data)
      decipher = OpenSSL::Cipher::Cipher.new(CIPHER)
      decipher.decrypt
      decipher.key = Digest::SHA256.digest(password)
      decipher.iv  = iv
      decipher.update(secretdata) + decipher.final
    end

    # Encrypt given plaintext data
    #
    # @param data [String] base64 encoded data
    # @param password [String] password
    # @param iv [String] initialization vector used for encryption
    # @return [String] base64 encoded encrypted data
    def self.encrypt(data, password, iv)
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.encrypt # set cipher to be encryption mode
      cipher.key = Digest::SHA256.digest(password)
      cipher.iv  = iv

      encrypted = ''
      encrypted << cipher.update(data)
      encrypted << cipher.final
      Base64.encode64(encrypted).gsub(/\n/, '')
    end
  end
end

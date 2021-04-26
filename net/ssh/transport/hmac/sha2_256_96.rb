require Rails.root.join('net/ssh/transport/hmac/abstract.rb')

module Net::SSH::Transport::HMAC
  # The SHA256-96 HMAC algorithm. This returns only the first 12 bytes of
  # the digest.
  class SHA2_256_96 < SHA2_256
    mac_length 12
  end
end

require Rails.root.join('net/ssh/transport/hmac/md5.rb')

module Net::SSH::Transport::HMAC

  # The MD5-96 HMAC algorithm. This returns only the first 12 bytes of
  # the digest.
  class MD5_96 < MD5
    mac_length 12
  end

end

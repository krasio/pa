module Pa
  class NullSSHGateway
    def initialize(port)
      @port = port
    end

    def open(remote_host, remote_port, local_port, &blk)
      blk.call(@port)
    end

    def shutdown!
    end
  end
end

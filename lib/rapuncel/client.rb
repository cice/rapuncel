require 'rapuncel/adapters/net_http_adapter'
require 'rapuncel/connection'
require 'active_support/core_ext/hash/except'

module Rapuncel
  class Client
    attr_accessor :connection, :raise_on_fault, :raise_on_error

    include Adapters::NetHttpAdapter

    def proxy_for interface
      Proxy.new self, interface
    end

    def proxy
      proxy_for nil
    end

    def initialize configuration = {}
      @connection = Connection.build configuration.except(:raise_on)

      @raise_on_fault, @raise_on_error = case configuration[:raise_on]
      when :fault
        [true, false]
      when :error
        [false, true]
      when :both
        [true, true]
      else
        [false, false]
      end
    end

    def call name, *args
      execute Request.new(name, *args)
    end

    def call_to_ruby name, *args
      response = call name, *args

      raise_on_fault && response.fault? && raise(Response::Fault, response.fault.inspect)
      raise_on_error && response.error? && raise(Response::Error, response.error.inspect)

      response.to_ruby
    end

    protected
    def execute request
      xml = request.to_xml_rpc

      Response.new send_method_call(xml)
    end
  end
end
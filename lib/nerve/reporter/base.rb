
class Nerve::Reporter
  class Base
    include Nerve::Utils
    include Nerve::Logging

    def initialize(opts)
    end

    def start
    end

    def stop
    end

    def report_up
    end

    def report_down
    end

    def update_data(new_data='')
    end

    def ping?
    end

    def get_service_data(service)
      %w{instance_id host port}.each do |required|
        raise ArgumentError, "missing required argument #{required} for new service watcher" unless service[required]
      end
      {'host' => service['host'], 'port' => service['port'], 'name' => service['instance_id'], 'extra' => (service['extra'] || {})}
    end

    protected
    def parse_data(data)
      return data if data.class == String
      return data.to_json
    end
  end
end


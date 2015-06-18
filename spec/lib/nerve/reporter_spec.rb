require 'spec_helper'
require 'nerve/reporter/zookeeper'

describe Nerve::Reporter do
  let(:subject) { {
      'zk_hosts' => ['zkhost1', 'zkhost2'],
      'zk_path' => 'zk_path',
      'instance_id' => 'instance_id',
      'host' => 'host',
      'port' => 'port'
    }
  }
  it 'can new_from_service' do
    expect(Nerve::Reporter::Zookeeper).to receive(:new).with(subject).and_return('kerplunk')
    expect(Nerve::Reporter.new_from_service(subject)).to eq('kerplunk')
  end
  it 'actually constructs an instance of a specific backend' do
    expect(Nerve::Reporter.new_from_service(subject).is_a?(Nerve::Reporter::Zookeeper)).to eql(true)
  end
  it 'the reporter backend inherits from the base class' do
    expect(Nerve::Reporter.new_from_service(subject).is_a?(Nerve::Reporter::Base)).to eql(true)
  end
  it 'throws ArgumentError if you ask for a reporter type which does not exist' do
    subject['reporter_type'] = 'does_not_exist'
    expect { Nerve::Reporter.new_from_service(subject) }.to raise_error(ArgumentError)
  end
end

class Nerve::Reporter::Test < Nerve::Reporter::Base
end

describe Nerve::Reporter::Test do
  let(:subject) {Nerve::Reporter::Test.new({}) }
  context 'parse_data method' do
    it 'has parse data method that passes strings' do
      expect(subject.send(:parse_data, 'foobar')).to eql('foobar')
    end
    it 'jsonifies anything that is not a string' do
      thing_to_parse = double()
      expect(thing_to_parse).to receive(:to_json).and_return('{"some":"json"}')
      expect(subject.send(:parse_data, thing_to_parse)).to eql('{"some":"json"}')
    end
  end

  context 'get_service_data method' do
    it 'throws on missing arguments' do
      expect { subject.get_service_data({'host' => '127.0.0.1', 'port' => 6666}) }.to raise_error(ArgumentError)
      expect { subject.get_service_data({'host' => '127.0.0.1', 'instance_id' => 'foobar'}) }.to raise_error(ArgumentError)
      expect { subject.get_service_data({'port' => 6666, 'instance_id' => 'foobar'}) }.to raise_error(ArgumentError)
      expect { subject.get_service_data({'host' => '127.0.0.1', 'port' => 6666, 'instance_id' => 'foobar'}) }.not_to raise_error
    end
    it 'takes extra data if present' do
      expect(subject.get_service_data({'host' => '127.0.0.1', 'port' => 6666, 'instance_id' => 'foobar', 'extra' => {'foo' => 'bar'}})['extra']).to eql({'foo' => 'bar'})
    end
    it 'defaults extra data if not present' do
      expect(subject.get_service_data({'host' => '127.0.0.1', 'port' => 6666, 'instance_id' => 'foobar'})['extra']).to eql({})
    end
  end
end


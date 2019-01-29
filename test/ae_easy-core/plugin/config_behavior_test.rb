require 'test_helper'

describe 'config behavior' do
  before do
    # Config behavior object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::ConfigBehavior
    end
  end

  describe 'unit test' do
    it '' do
      
    end
  end
end

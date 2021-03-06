require 'spec_helper'

module Vcloud
  module Walker
    module Resource

      class TestData < Entity
        attr_accessor :name

        def initialize data
          self.name = data.name
        end
      end

      class TestDataCollection < Collection
        def initialize coll
          coll.each do |c|
            self << Vcloud::Walker::Resource::TestData.new(c)
          end
        end

      end

      class TestClass < Entity
        attr_accessor :test_data
        attr_accessor :description

        def initialize test
          self.test_data   = TestDataCollection.new(test.collection)
          self.description = test.description
        end
      end

      class TestNestedEntity < Entity
        attr_accessor :test_data
        def initialize data
          self.test_data = TestData.new(data)
        end
      end

    end
  end

  describe Vcloud::Walker::Resource::Entity do
    it 'should be able to nested collections inside entities' do
      collection = [double(:name => 'collection 1'), double(:name => 'collection 2')]
      test_class = Vcloud::Walker::Resource::TestClass.new(
        double(:description => 'test class desc', :collection => collection)
      )
      expect(test_class.to_summary).to eq({
        :test_data => [
          {:name => "collection 1"}, {:name => "collection 2"}
        ],
        :description => "test class desc"
      })
    end

    it 'should summaries a class as a hash and remove @ from the symbol names' do
      collection = [double(:name => 'collection 1'), double(:name => 'collection 2')]
      test_class = Vcloud::Walker::Resource::TestClass.new(
        double(:description => 'test class desc', :collection => collection)
      )
      expect(test_class.instance_variables).to eq([:@test_data, :@description])
      test_summary = test_class.to_summary
      expect(test_summary.keys).to eq([:test_data, :description])
    end

    it 'should be able to nest entity inside entity' do
      nested_entities = Vcloud::Walker::Resource::TestNestedEntity.new(
        double(:data, :name => 'Data 1')
      )
      expect(nested_entities.to_summary).to eq({:test_data=>{:name=>"Data 1"}})
    end

  end
end



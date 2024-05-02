# frozen_string_literal: true

FlatParams = Class.new
FlatQuery = Class.new
FlatCommand = Class.new

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Nina

        builder :main do
          factory :params, produces: FlatParams
          factory :query, produces: FlatQuery
          factory :command, produces: FlatCommand
        end
      end
    end
  end

  it 'builds object' do
    builder = abstract_factory.main_builder
    result = builder.enrich(abstract_factory.new) do |b|
      b.params
      b.command
    end
    expect(result).to be_a abstract_factory
    expect(result.params).to be_a FlatParams
    expect(result.command).to be_a FlatCommand
    expect { result.query }.to raise_error(NoMethodError)
  end
end

require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

        context 'model function' do
            let!(:node) { build(:taxonomite_node) }

            it 'instantiates a node' do
                expect(node.class.name).to eq("Taxonomite::Node")
            end

            it 'destroys a node' do
                expect { node.destroy }.not_to raise_error
            end

            it 'sets the name' do
                node.name = "new_name"
                expect(node.name).to eq("new_name")
            end

            it 'allow access to children' do
                expect { node.children! }.not_to raise_error
            end

            it 'allow access to parent' do
                expect { node.parent! }.not_to raise_error
            end

        end

    end
end

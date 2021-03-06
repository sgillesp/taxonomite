require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

        context 'node function' do
            let!(:node) { build(:taxonomite_node) }

            it 'instantiates a node' do
                expect(node.class.name).to eq("Taxonomite::Node")
            end

            it 'destroys a node' do
                expect { node.destroy }.not_to raise_error
            end

            it 'allow access to children' do
                expect { node.children }.not_to raise_error
            end

            it 'allow access to parent' do
                expect { node.parent }.not_to raise_error
            end

            it 'has a working == operator' do
                node2 = build(:taxonomite_node)
                expect(node == node).to eq(true)
                expect(node == node2).to eq(false)
                expect(node != node2).to eq(true)
            end
        end

    end
end

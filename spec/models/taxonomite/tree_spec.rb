require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

      context 'tree creation' do
          let!(:nodes) { Array.new(3){ |index| build(:taxonomite_node)} }

          it 'to disallow direct circular reference' do
              # rephrase to check validity
              expect { nodes[0].children << nodes[0] }.to raise_error
          end

          it 'to disallow circular reference (one deep)' do
               nodes[0].children << nodes[1]
               expect { nodes[1].children << nodes[0] }.to raise_error
          end
      end

      context 'tree structure' do
        before(:each) do
          @nodes = Array.new(3) { build(:taxonomite_node) }
          @nodes[0].children << @nodes[1]
          @nodes[1].children << @nodes[2]
        end

          it 'has appropriate children' do
            expect(@nodes[0].children.size).to eq(1)
          end

          it 'to disallow circular reference (two deep)' do
              expect { @nodes[2].children << @nodes[0] }.to raise_error
          end

          it 'to iterate children' do
              @nodes[0].children.each do |p|
                  expect(p).not_to eq(nil)
              end
          end

          it 'to allow real access to parent' do
              expect(@nodes[1].parent).not_to eq(nil)
              expect { @nodes[1].parent.name }.not_to raise_error
          end

          it 'ok to destroy a parent object safely' do
              expect { @nodes[0].destroy }.not_to raise_error
              expect(@nodes[1].parent).to eq(nil)
              expect(@nodes[2].parent).not_to eq(nil)
          end

      end

    end
end

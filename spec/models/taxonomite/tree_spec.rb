require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

      context 'tree creation' do
          let!(:nodes) { Array.new(3){ |index| build(:taxonomite_node)} }

          it 'allows addition of children' do
              expect { nodes[0].add_child(nodes[1]) }.not_to raise_error
          end

          it 'allows addition of parent' do
              expect { nodes[0].add_parent(nodes[1]) }.not_to raise_error
          end

          it 'to disallow direct circular reference' do
              expect { nodes[0].add_child(nodes[0]) }.to raise_error
          end

          it 'to disallow circular reference (one deep)' do
               nodes[0].add_child(nodes[1])
               expect { nodes[1].add_child(nodes[0]) }.to raise_error
          end

          it 'remove parent works as expected, parents child becomes nil' do
               nodes[0].add_child(nodes[1])
               expect { nodes[1].rem_parent }.not_to raise_error
               expect(nodes[0].children!.size).to eq(0)
          end

          it 'remove child works as expected, child parent becomes nil' do
               nodes[0].add_child(nodes[1])
               expect { nodes[0].rem_child(nodes[1]) }.not_to raise_error
               expect(nodes[0].children!.size).to eq(0)
               expect(nodes[1].parent!).nil?
          end

      end

      context 'tree structure' do
        before(:each) do
          @nodes = Array.new(3) { build(:taxonomite_node) }
          @nodes[0].add_child(@nodes[1])
          @nodes[1].add_child(@nodes[2])
        end

          it 'has appropriate number of children' do
            expect(@nodes[0].children!.size).to eq(1)
          end

          it 'to disallow circular reference (two deep)' do
              expect { @nodes[2].add_child(@nodes[0]) }.to raise_error
          end

          it 'to iterate children' do
              @nodes[0].children!.each do |p|
                  expect(p).not_to eq(nil)
              end
          end

          it 'to allow real access to parent' do
              expect(@nodes[1].parent!).not_to eq(nil)
              expect { @nodes[1].parent!.name }.not_to raise_error
          end

          it 'ok to destroy a parent object safely' do
              expect { @nodes[0].destroy }.not_to raise_error
              expect(@nodes[1].parent!).to eq(nil)
              expect(@nodes[2].parent!).not_to eq(nil)
          end

      end

    end
end

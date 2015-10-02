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
               expect { nodes[1].remove_parent }.not_to raise_error
               expect(nodes[0].children.size).to eq(0)
          end

          it 'remove child works as expected, child parent becomes nil' do
               nodes[0].add_child(nodes[1])
               expect { nodes[0].remove_child(nodes[1]) }.not_to raise_error
               expect(nodes[0].children.size).to eq(0)
               expect(nodes[1].parent).nil?
          end

      end

      context 'tree structure' do
        before(:each) do
          @nodes = Array.new(4) { build(:taxonomite_node) }
          @nodes[0].add_child(@nodes[1])
          @nodes[1].add_child(@nodes[2])
          @nodes[0].add_child(@nodes[3])
        end

          it 'has appropriate number of children' do
            expect(@nodes[0].children.size).to eq(2)
          end

          it 'to disallow circular reference (two deep)' do
              expect { @nodes[2].add_child(@nodes[0]) }.to raise_error
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
              expect(@nodes[3].parent).to eq(nil)
          end

          it 'successfully finds leaves of the tree' do
              expect(@nodes[0].leaves.size).to eq(2)
              expect(@nodes[0].leaves.find(@nodes[3])).not_to eq(nil)
          end

          it 'successfully finds the root of the tree' do
              expect(@nodes[2].root).to eq(@nodes[0])
              expect(@nodes[3].root).to eq(@nodes[0])
          end

          it 'successfully identifies anscestor' do
              expect(@nodes[2].descendant_of?(@nodes[0])).to eq(true)
              expect(@nodes[0].descendant_of?(@nodes[2])).to eq(false)
          end

          it 'successfully identifies descendant' do
              expect(@nodes[2].ancestor_of?(@nodes[0])).to eq(false)
              expect(@nodes[0].ancestor_of?(@nodes[2])).to eq(true)
          end

          it 'can aggregate ancestors' do
            expect { @nodes[0].ancestors.map { |n| n.evaluate('name') } }.not_to raise_error
          end

          it 'accurately aggregates self and ancestors' do
              a = @nodes[2].self_and_ancestors.map { |n| n.evaluate ('name') }
              expect(a.size).to eq(3)
              expect(a.include?(@nodes[3].name)).not_to eq(true)
              expect(a.include?(@nodes[2].name)).to eq(true)
              expect(a.include?(@nodes[1].name)).to eq(true)
              expect(a.include?(@nodes[0].name)).to eq(true)
          end

          it 'accurately aggregates ancestors without self' do
              a = @nodes[2].ancestors.map { |n| n.evaluate ('name') }
              expect(a.size).to eq(2)
              expect(a.include?(@nodes[3].name)).not_to eq(true)
              expect(a.include?(@nodes[2].name)).not_to eq(true)
              expect(a.include?(@nodes[1].name)).to eq(true)
              expect(a.include?(@nodes[0].name)).to eq(true)
          end

          it 'can aggregate self and descendants' do
              expect { @nodes[0].self_and_descendants.map { |n| n.evaluate('name') } }.not_to raise_error
          end

          it 'accurately aggregates self and descendants' do
              a = @nodes[0].self_and_descendants.map { |n| n.evaluate ('name') }
              expect(a.size).to eq(4)
              expect(a.include?(@nodes[3].name)).to eq(true)
              expect(a.include?(@nodes[2].name)).to eq(true)
              expect(a.include?(@nodes[1].name)).to eq(true)
              expect(a.include?(@nodes[0].name)).to eq(true)
          end

          it 'accurately aggregates descendants without self' do
            a = @nodes[0].descendants.map { |n| n.evaluate ('name') }
            expect(a.size).to eq(3)
            expect(a.include?(@nodes[3].name)).to eq(true)
            expect(a.include?(@nodes[2].name)).to eq(true)
            expect(a.include?(@nodes[1].name)).to eq(true)
            expect(a.include?(@nodes[0].name)).not_to eq(true)
          end

          it 'aggregates leaf values without causing exception' do
            expect { @nodes[0].leaves.map { |n| n.evaluate('name') } }.not_to raise_error
          end

          it 'accurately aggregates leaf values' do
              a = @nodes[0].leaves.map { |n| n.evaluate('name') }

              expect(a.include?(@nodes[3].name)).to eq(true)
              expect(a.include?(@nodes[2].name)).to eq(true)
              expect(a.include?(@nodes[1].name)).not_to eq(true)
              expect(a.include?(@nodes[0].name)).not_to eq(true)
          end

      end

    end
end

# frozen_string_literal: true

describe Nanoc::Int::OutdatednessStore do
  subject(:store) { described_class.new(site: site) }

  let(:site) { double(:site) }

  let(:item) { Nanoc::Int::Item.new('foo', {}, '/foo.md') }
  let(:rep) { Nanoc::Int::ItemRep.new(item, :foo) }

  let(:site) do
    Nanoc::Int::Site.new(
      config: config,
      code_snippets: code_snippets,
      data_source: Nanoc::Int::InMemDataSource.new(items, layouts),
    )
  end

  let(:config) { Nanoc::Int::Configuration.new.with_defaults }
  let(:items) { [] }
  let(:layouts) { [] }
  let(:code_snippets) { [] }

  shared_examples 'include check' do
    context 'nothing added' do
      it { is_expected.not_to be }
    end

    context 'rep added' do
      before { store.add(rep) }
      it { is_expected.to be }
    end

    context 'rep added and removed' do
      before do
        store.add(rep)
        store.remove(rep)
      end

      it { is_expected.not_to be }
    end

    context 'rep added, removed, and added again' do
      before do
        store.add(rep)
        store.remove(rep)
        store.add(rep)
      end

      it { is_expected.to be }
    end
  end

  describe '#include?, #add and #remove' do
    context 'with rep' do
      subject { store.include?(rep) }
      include_examples 'include check'
    end

    context 'with rep reference' do
      subject { store.include?(rep.reference) }
      include_examples 'include check'
    end
  end

  describe 'reloading' do
    subject do
      store.store
      store.load
      store.include?(rep)
    end

    context 'not added' do
      it { is_expected.not_to be }
    end

    context 'added' do
      before { store.add(rep) }
      it { is_expected.to be }
    end
  end
end

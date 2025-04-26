# frozen_string_literal: true
# require 'rspec'
require_relative '../word_splitter'

RSpec.describe WordSplitter do
  let(:splitter) { WordSplitter.new(dictionary) }
  subject { splitter.can_split?(string) }

  describe '#can_split?' do
    def self.test_case
      it { is_expected.to eq(expected_result) }
    end

    context 'when string can be segmented' do
      let(:dictionary) { %w[две сотни тысячи] }
      let(:string) { 'двесотни' }
      let(:expected_result) { true }
      test_case
    end

    context 'when string cannot be segmented' do
      let(:dictionary) { %w[две тысячи] }
      let(:string) { 'двесотни' }
      let(:expected_result) { false }
      test_case
    end

    context 'with empty string' do
      let(:dictionary) { [] }
      let(:string) { '' }
      let(:expected_result) { true }
      test_case
    end

    context 'with single exact match' do
      let(:dictionary) { ['apple'] }
      let(:string) { 'apple' }
      let(:expected_result) { true }
      test_case
    end

    context 'when no words match' do
      let(:dictionary) { ['banana'] }
      let(:string) { 'apple' }
      let(:expected_result) { false }
      test_case
    end

    context 'with multiple splits required' do
      let(:dictionary) { %w[apple pen applepen] }
      let(:string) { 'applepenapple' }
      let(:expected_result) { true }
      test_case
    end

    context 'when part of string does not match' do
      let(:dictionary) { ['две', 'сот'] }
      let(:string) { 'двесотни' }
      let(:expected_result) { false }
      test_case
    end
  end
end

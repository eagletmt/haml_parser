require 'spec_helper'

RSpec.describe HamlParser::IndentTracker do
  it 'raises error if indent is wrong' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::IndentTracker::IndentMismatch) { |e|
%div
    %div
        %div
  %div
HAML
      aggregate_failures do
        expect(e.current_level).to eq(2)
        expect(e.indent_levels).to eq([0])
        expect(e.lineno).to eq(4)
      end
    }
  end

  it 'raises error if the current indent is deeper than the previous one' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::IndentTracker::InconsistentIndent) { |e|
%div
  %div
      %div
HAML
      aggregate_failures do
        expect(e.previous_size).to eq(2)
        expect(e.current_size).to eq(4)
        expect(e.lineno).to eq(3)
      end
    }
  end

  it 'raises error if the current indent is shallower than the previous one' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::IndentTracker::InconsistentIndent) { |e|
%div
    %div
      %div
HAML
      aggregate_failures do
        expect(e.previous_size).to eq(4)
        expect(e.current_size).to eq(2)
        expect(e.lineno).to eq(3)
      end
    }
  end

  it 'raises error if indented with hard tabs' do
    expect { parse(<<HAML) }.to raise_error(HamlParser::IndentTracker::HardTabNotAllowed)
%p
	%a
HAML
  end
end


require 'spec_helper'


describe Rufus::Scheduler do

  describe '.parse' do

    def parse(s)
      Rufus::Scheduler.parse(s)
    end

    it 'parses duration strings' do

      parse('1.0d1.0w1.0d').should == 777600.0
    end

    it 'parses datetimes' do

      parse('Sun Nov 18 16:01:00 JST 2012').to_s.should match(
        /2012-11-18 16:01:00 \+\d{4}/)
    end

    it 'parses cronlines'

    it 'raises on unparseable input' do

      lambda {
        parse('nada')
      }.should raise_error(ArgumentError, 'no time information in "nada"')
    end
  end

  describe '.parse_duration' do

    def pd(s)
      Rufus::Scheduler.parse_duration(s)
    end

    it 'parses duration strings' do

      pd('-1.0d1.0w1.0d').should == -777600.0
      pd('-1d1w1d').should == -777600.0
      pd('-1w2d').should == -777600.0
      pd('-1h10s').should == -3610.0
      pd('-1h').should == -3600.0
      pd('-5.').should == -5.0
      pd('-2.5s').should == -2.5
      pd('-1s').should == -1.0
      pd('-500').should == -0.5
      pd('').should == 0.0
      pd('5.0').should == 5.0
      pd('0.5').should == 0.5
      pd('.5').should == 0.5
      pd('5.').should == 5.0
      pd('500').should == 0.5
      pd('1000').should == 1.0
      pd('1').should == 0.001
      pd('1s').should == 1.0
      pd('2.5s').should == 2.5
      pd('1h').should == 3600.0
      pd('1h10s').should == 3610.0
      pd('1w2d').should == 777600.0
      pd('1d1w1d').should == 777600.0
      pd('1.0d1.0w1.0d').should == 777600.0

      pd('.5m').should == 30.0
      pd('5.m').should == 300.0
      pd('1m.5s').should == 60.5
      pd('-.5m').should == -30.0
    end

    it 'raises on wrong duration strings' do

      lambda { pd('-') }.should raise_error(ArgumentError)
      lambda { pd('h') }.should raise_error(ArgumentError)
      lambda { pd('whatever') }.should raise_error(ArgumentError)
      lambda { pd('hms') }.should raise_error(ArgumentError)

      lambda { pd(' 1h ') }.should raise_error(ArgumentError)
    end
  end

  describe '.to_duration' do

    def td(o, opts={})
      Rufus::Scheduler.to_duration(o, opts)
    end

    it 'turns integers into duration strings' do

      td(0).should == '0s'
      td(60).should == '1m'
      td(61).should == '1m1s'
      td(3661).should == '1h1m1s'
      td(24 * 3600).should == '1d'
      td(7 * 24 * 3600 + 1).should == '1w1s'
      td(30 * 24 * 3600 + 1).should == '4w2d1s'
    end

    it 'ignores seconds and milliseconds if :drop_seconds => true' do

      td(0, :drop_seconds => true).should == '0m'
      td(5, :drop_seconds => true).should == '0m'
      td(61, :drop_seconds => true).should == '1m'
    end

    it 'displays months if :months => true' do

      td(1, :months => true).should == '1s'
      td(30 * 24 * 3600 + 1, :months => true).should == '1M1s'
    end

    it 'turns floats into duration strings' do

      td(0.1).should == '100'
      td(1.1).should == '1s100'
    end
  end

  describe '.to_duration_hash' do

    def tdh(o, opts={})
      Rufus::Scheduler.to_duration_hash(o, opts)
    end

    it 'turns integers duration hashes' do

      tdh(0).should == {}
      tdh(60).should == { :m => 1 }
    end

    it 'turns floats duration hashes' do

      tdh(0.128).should == { :ms => 128 }
      tdh(60.127).should == { :m => 1, :ms => 127 }
    end

    it 'drops seconds and milliseconds if :drop_seconds => true' do

      tdh(61.127).should == { :m => 1, :s => 1, :ms => 127 }
      tdh(61.127, :drop_seconds => true).should == { :m => 1 }
    end
  end
end

require 'test/unit'
require 'duration'

class TestDuration < Test::Unit::TestCase
	def test_tlist
		test_data = [
			[ [ "12", "30", "34", "345" ], "12:30:34,345" ],
			[ [ "12", "30", "34", "000" ], "12:30:34" ],
			[ [ "00", "30", "34", "345" ], "30:34,345" ],
			[ [ "00", "00", "34", "345" ], "34,345" ],
			[ [ "00", "00", "00", "050" ], "50" ],
			[ [ "00", "00", "00", "005" ], "00,005" ]
		]

		test_data.each {|data| assert(data[0],data[1].to_tlist) }
	end

	def test_tlist_size_less_2
		assert_equals( [ "00", "02", "50", "000" ], "2:50".to_tlist )
	end

	def test_tlist_false
		assert_equals( ["23","12","34","234"], "23:34".to_tlist )
	end

	def test_add()
		test_data = [
			[ "00:00:00,000", "5", "00:00:00,005" ],
			[ "01:23:59,000", "1", "01:23:59,001" ],
			[ "01:23:59,000", "1:01", "01:25:00,000" ],
			[ "01:23:59,000", "1:36:01", "03:00:00,000" ],
			[ "00:00:00,345", "00,005", "00:00:00,350" ],
			[ "00:00:00,345", "01,655", "00:00:02,000" ],
			[ "01:58:59,980", "2,220", "01:59:02,200"]
		]
		test_data.each {|data| assert(data[0].add(data[1]), data[2])}
	end

	def test_sub()
		test_data = [
			[ "01:58:59"]
		]
	end	
end



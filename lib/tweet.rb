#require "rubygems"
#require "active_support/core_ext"
#require "test/unit"

class Tweet
  class Invalid < Exception; end

  attr_accessor :text, :user, :quantity, :drink, :memo

  def initialize(text)
    self.text = text
    self.parse
    raise Invalid if [user, quantity, drink].any?(&:blank?)
  end

  def drink=(drink)
    @drink = drink.to_s.gsub(/#buddybeer/, "").strip.presence || "beer"
  end

  def quantity=(quantity)
    @quantity = (quantity.to_s.gsub(/a/, "").strip.presence || 1).to_i
  end

  def drink=(drink)
    @drink = drink.to_s.gsub(/#buddybeer/, "").strip.presence || "beer"
  end

  def memo=(memo)
    @memo = memo.to_s.gsub(/#buddybeers?/, "").strip
  end

protected

  def parse
    self.text =~ /io \@(\w+)\s*(|a|\d+) (#buddybeer|beer)s?( for )?((.*)#buddybeers?|(.*))/i
    self.user, self.quantity, self.drink, self.memo = $1, $2, $3, $5
  end
end

if $0 == __FILE__
  class TweetTest < Test::Unit::TestCase
    def setup
      @tweet = Tweet.new("IO @matid a beer for writing me a regex to parse this tweet #buddybeer")
    end

    def test_user
      assert_equal "matid", @tweet.user
    end

    def test_drink
      assert_equal "beer", @tweet.drink
    end

    def test_quantity
      assert_equal 1, @tweet.quantity
    end

    def test_memo
      assert_equal "writing me a regex to parse this tweet", @tweet.memo
    end

    def test_users_with_dashes
      tweet = Tweet.new("IO @user_with_dashes a beer for writing me a regex to parse this tweet #buddybeers")
      assert_equal "user_with_dashes", tweet.user
    end

    def test_numeric_quantity
      tweet = Tweet.new("IO @user 2 beers for a favour #buddybeer")
      assert_equal 2, tweet.quantity
    end

    def test_default_quantity
      tweet = Tweet.new("IO @user beer for a favour #buddybeer")
      assert_equal 1, tweet.quantity
    end

    def test_inline_hashtag
      tweet = Tweet.new("IO @user #buddybeer for a favour")
      assert_equal "beer", tweet.drink
      assert_equal "a favour", tweet.memo
    end

    def test_no_memo
      tweet = Tweet.new("IO @user a beer #buddybeer")
      assert_equal "beer", tweet.drink
      assert tweet.memo.blank?
    end

    def test_no_memo_with_inline_hashtag
      tweet = Tweet.new("IO @user #buddybeer")
      assert_equal "beer", tweet.drink
      assert tweet.memo.blank?
    end

    def test_raising_exceptions_on_incorrect_tweets
      assert_raise(Tweet::Invalid){ Tweet.new("WTF?") }
    end
  end
end
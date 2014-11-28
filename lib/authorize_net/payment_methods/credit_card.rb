module AuthorizeNet
  
  # Defines constants for each payment method type.
  module PaymentMethodType
    CREDIT_CARD = 'CC'
  end
  
  # Models a credit card.
  class CreditCard
    PAYMENT_METHOD_CODE = AuthorizeNet::PaymentMethodType::CREDIT_CARD
    
    # The option defaults for the constructor.
    @@option_defaults = {
      :card_code => nil,
      :card_type => nil
    }
    
    attr_accessor :card_number, :expiration, :card_code, :card_type, :track_1, :track_2
    
    # Constructs a new credit card object. Takes a credit card number
    # and an expiration date. The CCV code can be passed as an option. So can
    # the data tracks (1 & 2). When passing in data tracks, please pass the
    # whole track. Sentinels and the LRC will be removed by the SDK. Track data
    # must be passed along as ASCII. The raw bit stream from the card is not acceptable.
    # 
    # Field separators on
    # 
    # +card_number+:: The credit card number as a string.
    # +expiration+:: The credit card expiration date as a string with format MMYY.
    # +options+:: A hash of options.
    # 
    # Options
    # +card_code+:: Sets the CCV code for the credit card.
    # +card_type+:: Sets the type of card (Visa, MasterCard, Dinners Club, etc.)
    # +track_1+:: Sets the track 1 data. Either track 1 or track 2 data needs to be included for card present transactions (otherwise fee structure will change).
    # +track_2+:: Sets the track 2 data. Either track 1 or track 2 data needs to be included for card present transactions (otherwise fee structure will change).
    #
    # 
    def initialize(card_number, expiration, options = {})
      @card_number = card_number
      @expiration = expiration
      options = @@option_defaults.merge(options)
      @card_code = options[:card_code]
      @card_type = options[:card_type]
      @track_1 = options[:track_1]
      @track_2 = options[:track_2]
    end
    
    def to_hash
      hash = {
        :method => PAYMENT_METHOD_CODE,
        :card_num => @card_number,
        :exp_date => @expiration
      }
      hash[:card_code] = @card_code unless @card_code.nil?

      hash[:track1] = strip_sentinels(@track_1, '%', '?') unless @track_1.nil?
      hash[:track2] = strip_sentinels(@track_2, ';', '?') unless @track_2.nil?
      hash
    end

    def strip_sentinels(track, begin_sign, end_sign)
      result = track
      index = track.rindex(end_sign)
      if result[0..0] == begin_sign && index.present?
        result = result[1..(index - 1)]
      end
      result
    end
  end
end

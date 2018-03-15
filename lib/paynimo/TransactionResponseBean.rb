module Paynimo
	class TransactionResponseBean
	
	  protected
	  @responsePayload
	  @key
	  @iv  
	  @blockSize
	  @mode
	  
	  public
	  attr_accessor :responsePayload
	  attr_accessor :key
	  attr_accessor :iv  
	  attr_accessor :blocksize
	  attr_accessor :mode  
	  
	  def initialize
	  
	    	# setting initial value (optional)
	    	@blockSize = 128
	    	@mode = "cbc"
	    	    	
	  end
	  	
	  # This function decrypts the final response and returns it to the merchant.
	  # * *Returns* :
	  #   - +string+ -> the result decryptResponse
	  
	  def getResponsePayload
	  
		begin
			_requestValidate = Paynimo::RequestValidate.new
			_responseParams = {}
			_responseParams[:pRes] = @responsePayload		
			_responseParams[:pEncKey] = @key
			_responseParams[:pEncIv] = @iv
					
			_errorResponse = _requestValidate.validateResponseParam(_responseParams)
			
			if _errorResponse
				return _errorResponse
			end
			
			_aes = Paynimo::AES.new(@responsePayload,@key,@blockSize,@mode,@iv)
			
			_decryptResponse = _aes.decrypt.gsub(/[\x00-\x1F\x7F]/, '').strip
				return _decryptResponse
			_implodedResp = _decryptResponse.split('|') 
			_hashCodeString = _implodedResp.last
			_implodedResp.pop
			
			_explodedHashValue = _hashCodeString.split('=')
			_hashValue =  _explodedHashValue[1].strip
			
			_responseDataString = _implodedResp.join("|")
			_generatedHash = Digest::SHA1.hexdigest _responseDataString
			
			if _generatedHash == _hashValue
				return _decryptResponse
			else
				return "ERROR064"
			end
			
		rescue Exception => e  
	  		puts "Exception In TransactionResposeBean : :#{e.message}"
			return  
		end
		
		return "ERROR037"
		
	  end
	  
	end
end
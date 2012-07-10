class Exchange
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code                   # 4 letter id for the exchange
  field :state, type: Integer   # the state of this exchange
  field :shortname              # Exchange short name
  field :name                   # Exchange name
  field :country                # Exchange country
  field :region                 # Exchange region
  field :town                   # Exchange town
  field :website                # Exchange website
  field :map                    # Exchange map
  field :currencysymbol
  field :currencyname
  field :currenciesname
  field :currencyvalue, type: BigDecimal # Value of this currency
  field :currencyscale, type: Integer    # How many decimals use for this currency. Between 0 and 4

  belongs_to :limit_chain       # default limit chain for this exchange
  has_many :accounts

  # this should be managed with groups (more than one user as admin for an exchange?)
  belongs_to :admin, :class_name => "User", :foreign_key => "admin_id"

  validates :code, allow_nil: false
  validates :state, numericality: { greater_than_or_equal_to: 0 }
  validates :currencyscale, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }

  def currency
    Currency.new self
  end


  DEFAULT_EXCHANGE_ID = 1
  STATE_INACTIVE = 0
  STATE_ACTIVE = 1


  #
  # @return Exchange The default exchange. To be used as a model for new
  # exchanges. It is the exchange stored with id Exchange::DEFAULT_EXCHANGE_ID.
  #
  def self.default_exchange
    self.class.find(DEFAULT_EXCHANGE_ID)
  end

  #  /**
  # * @return LocalAccount to be used as a prototype for new accounts.
  # */
  def default_account
    LocalAccount.new do |acc|
      acc.exchange = self
      acc.name = free_account_name
      acc.balance = 0
      acc.state = :hidden
      acc.kind = :individual
      acc.limit_chain = self.limit_chain
    end
    # todo add a role for current_user on the created account, with :administrator permissions
  end


  def free_account_name
    account_codes = Set[*accounts.only(:code).collect(&:code)]
    free_code = (0..9999).detect {|i|
      not account_codes.include? i
    }
    "%04d" % free_code
  end

  # Activates a newly created exchange. Creates all the additional structures an
  # exchange needs in order to be operative. This includes:
  #  - default limit chain
  # And sets up the active flag to this exchange.
  # Exchange needs to be saved after this call so the state flag persists.
  #
  def activate
    unless @limit_chain
      lc = self.class.default_exchange.default_account.limit_chain
      lc.id = nil
      @limit_chain = lc
    end
    # unless @virtual_account
    #   va = self.default_account
    #   va.kind = :virtual
    #   va.state = :hidden
    #   va.name = "#{self.code}VIRT"
    #   @virtual_account = va
    # end
    self.state = :active
  end

  # /**
  #  * @return Account the virtual account for this exchange. It is created if it
  #  * doesn't exist.
  #  * @todo notify exchange admin in case of virtual user creation.
  #  */
  def virtual_account(exchange)
    name = "#{code}#{exchange.code}"
    va = LocalAccount.find_by_name(name)
    unless va
      va = LocalAccount.new do |a|
        a.exchange = self
        a.name = name
        a.balance = 0
        a.state = :hidden
        a.kind = :virtual
        a.limit_chain = limit_chain
      end
      b = Bank.new
      b.accounts << va
    end
    va
  end

end

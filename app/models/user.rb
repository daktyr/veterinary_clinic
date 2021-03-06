class User < ActiveRecord::Base
  include Gravtastic
  gravtastic default: 'mm', secure: true, rating: 'PG'

  enum role: [ :pacjent, :weterynarz, :admin ]

  has_one :address
  has_one :veterinarian
  has_many :medical_records
  has_many :animals
  has_many :appointments
  has_many :pictures
  accepts_nested_attributes_for :address

  #Rails_admin
  accepts_nested_attributes_for :veterinarian

  validates_presence_of :first_name, :last_name, :pesel, :phone_number
  validates :pesel, length: { is: 11 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  def update_attributes(params)
    if params[:password].blank?
      params.delete :password
      params.delete :password_confirmation
      super params
    end
  end

  def custom_label_method
    "##{id} #{first_name} #{last_name}, pesel: #{pesel}"
  end

  private

    def self.search(query)
      where("(lower(last_name) like :q OR lower(first_name) like :q) AND role = 0", { q: "%#{query.downcase}%" })
    end

    def self.veterinarian_search(query)
      where("(lower(last_name) like :q OR lower(first_name) like :q) AND role = 1", { q: "%#{query.downcase}%"})
    end
end

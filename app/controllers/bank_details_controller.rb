class BankDetailsController < InheritedResources::Base

  private

    def bank_detail_params
      params.require(:bank_detail).permit(:bank_name, :account_number, :created_at, :updated_at)
    end
end


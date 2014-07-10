defmodule Commerce.Payments.Response do
  defstruct [:success, :code, :avs_code, :cvc_code, :raw]
end

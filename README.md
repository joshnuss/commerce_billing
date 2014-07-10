Commerce.Payments
=================

Payment processing library for Elixir. Based on [Shopify's](http://shopify.com) [ActiveMerchanti](http://github.com/Shopify/active_merchant) ruby gem

Road Map
================

- Support multiple gateways (PayPal, Stripe, Authorize.net, Braintree etc..)
- Support gateways that bill directly and those that use html integrations.
- Each gateway is hosted in a worker process and supervised.
- Workers can be pooled. (using poolboy)
- Workers can be spread on multiple nodes
- The gateway is selected by first calling the "Gateway Factory" process. The "Gateway Factory" decides which gateway to use. Usually it will just be one type based on configuration setting in mix.exs (i.e. Stripe), but the Factory can be replaced with something fancier. It will enable scenarios like:
    - Use one gateway for visa another for mastercard
    - Use primary gateway (i.e PayPal), but when PayPal is erroring switch to secondary/backup gateway (i.e. Authorize.net)
    - Currency specific gateway, i.e. use one gateway type for USD another for CAD
- Retry on network failure

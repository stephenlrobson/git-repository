with payments as (
  
  select
        id as payment_id,
        orderid,
        paymentmethod,
        status,
        amount,
        created

    from {{ source('stripe', 'payment')}}

)

select * from payments
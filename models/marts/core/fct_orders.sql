with orders as (
    select * from {{ ref('stg_orders')}}
),

payments as (
    select * from {{ ref('stg_payments')}}
),

order_payments as (
    select
        order_id,
        sum( case when status = 'success' then amount) as amount
    from payments
    group by 1
)

fct_orders as (
    select 
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        payment_id,
        coalesce (order_payments.amount, 0) as amount
    from orders o
    left join order_payments p using (orderid)
)

select * from fct_orders
with orders as (
    select * from {{ ref('stg_orders')}}
),

payments as (
    select * from {{ ref('stg_payments')}}
),

order_payments as (
    select
        order_id,
        sum(case when status = 'success' then amount end) as amount
    from payments
    group by 1
),

fct_orders as (
    select 
        o.order_id,
        o.customer_id,
        o.order_date,
        coalesce (order_payments.amount, 0) as amount
    from orders o
    left join order_payments using (order_id)
)

select * from fct_orders
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
    )
}}

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
        coalesce (order_payments.amount, 0) as amount,
        o.days_since_ordered,
        o.is_status_pending,
        o.order_status
    from orders o
    left join order_payments using (order_id)
)

select * from fct_orders
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where order_date > (select max(order_date) from {{ this }}) 
{% endif %}
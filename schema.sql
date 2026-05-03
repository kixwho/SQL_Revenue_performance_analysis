--orders table
CREATE TABLE olist.orders (
    order_id text,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);

--payments table
CREATE TABLE olist.payments (
    order_id text,
    payment_sequential integer,
    payment_type text,
    payment_installments integer,
    payment_value numeric(10,2)
);

--order_items table
CREATE TABLE olist.order_items (
    order_id text,
    order_item_id integer,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp without time zone,
    price numeric(10,2),
    freight_value numeric(10,2)
);

--products table
CREATE TABLE olist.products (
    product_id text,
    product_category_name text,
    product_name_length numeric,
    product_description_length numeric,
    product_photos_qty integer,
    product_weight_g numeric,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric
);

--customers table
CREATE TABLE olist.customers (
    customer_id text,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    customer_city text,
    customer_state text
);
-- Вывести количество фильмов в каждой категории, отсортировать по убыванию.
select c.name, count(*)
from film f
inner join film_category fc on f.film_id = fc.film_id 
inner join category c on fc.category_id = c.category_id 
group by c.category_id 
order by count(*) desc;

-- Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select a.first_name, a.last_name, count(*)
from rental r
inner join inventory i on r.inventory_id = i.inventory_id 
inner join film f on i.film_id = f.film_id 
inner join film_actor fa on f.film_id = fa.film_id 
inner join actor a on fa.actor_id = a.actor_id 
group by a.actor_id 
order by count(*) desc
limit 10;

-- Вывести категорию фильмов, на которую потратили больше всего денег.
select c.name, sum(f.rental_duration*f.rental_rate) as total_rent
from rental r 
inner join inventory i ON r.inventory_id = i.inventory_id 
inner join film f ON f.film_id = i.film_id 
inner join film_category fc on fc.film_id = f.film_id 
inner join category c on c.category_id = fc.category_id 
group by c.category_id 
order by total_rent desc
limit 10;

-- Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
select f.title
from film f 
left join inventory i on f.film_id = i.film_id
where i.inventory_id is null;

-- Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
select a.first_name, a.last_name, count(*)
from film f 
inner join film_category fc on f.film_id = fc.film_id 
inner join category c on c.category_id = fc.category_id 
inner join film_actor fa on fa.film_id = f.film_id 
inner join actor a on a.actor_id = fa.actor_id 
where c.name = 'Children'
group by a.actor_id 
having count(*) >= (
select count(*)
from film f 
inner join film_category fc on f.film_id = fc.film_id 
inner join category c on c.category_id = fc.category_id 
inner join film_actor fa on fa.film_id = f.film_id 
inner join actor a on a.actor_id = fa.actor_id 
where c.name = 'Children'
group by a.actor_id
order by count(*) desc
limit 1 offset 2);

-- Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select ct.city, count(*), count(CASE WHEN cst.active = 1 THEN 1 END) as active, count(CASE WHEN cst.active = 0 THEN 1 END) as inactive
from customer cst
inner join address a on a.address_id = cst.address_id 
inner join city ct on a.city_id = ct.city_id 
group by ct.city_id
order by inactive desc;

-- Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
(select ctg.name, sum(extract(day from (r.return_date-r.rental_date))) as rental_hours
from city ct
inner join address a on a.city_id = ct.city_id 
inner join customer cst on a.address_id = cst.address_id 
inner join rental r on r.customer_id = cst.customer_id 
inner join inventory i on i.inventory_id = r.inventory_id 
inner join film f on f.film_id = i.film_id 
inner join film_category fc on fc.film_id = f.film_id 
inner join category ctg on ctg.category_id = fc.category_id 
where ct.city ilike 'a%'
group by ctg.category_id
order by rental_hours desc
limit 1)
union
(select ctg.name, sum(extract(day from (r.return_date-r.rental_date))) as rental_hours
from city ct
inner join address a on a.city_id = ct.city_id 
inner join customer cst on a.address_id = cst.address_id 
inner join rental r on r.customer_id = cst.customer_id 
inner join inventory i on i.inventory_id = r.inventory_id 
inner join film f on f.film_id = i.film_id 
inner join film_category fc on fc.film_id = f.film_id 
inner join category ctg on ctg.category_id = fc.category_id 
where ct.city like '%-%'
group by ctg.category_id
order by rental_hours desc
limit 1); 


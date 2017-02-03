/* Purpose: create a table that labels the total leaves in the family tree for each monster */

create or replace function element_by_monster() returns table(
		offspring varchar(10), 
		element_count integer)
as
$$ 

	declare 
		base_rows integer;
		breeding_rows integer;

	begin
    
    create temp table base on commit drop
	as
	select b.offspring, 2 as element_count
		from breeding b
	  where b.p1 in (select * from element)
	    and b.p2 in (select * from element)
	union all
    select b1.offspring, 1
  	    from breeding b1
  	  where b1.p1 is null
  	    and b1.p2 is null;

	loop

		insert into base
		select b.offspring, min(y.element_count + z.element_count) as element_count
			from (select * 
					from breeding 
				  union all
				  select 'boss family', 'servant', 'andreal')b
		    join (select base.offspring, base.element_count from base
		          union all
		          select *, 1 from element)y
		      on b.p1 = y.offspring
		    join (select base.offspring, base.element_count from base
		          union all
		          select *, 1 from element)z
		      on b.p2 = z.offspring
	      where b.offspring not in (select base.offspring from base)
	     group by b.offspring;
	    
		select count(*) into base_rows 
			from base;
		select count(distinct(breeding.offspring)) into breeding_rows
			from breeding; 

		exit when base_rows = breeding_rows + 1; 

    end loop;

    	delete from base
    		where base.offspring = 'boss family';

		return query select * from base;

	end;
$$
language plpgsql; 
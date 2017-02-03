/* Purpose: Function that measures that all breeding combinations required to produce a monster, with the shortest number of leaves on the family tree. */

create or replace function breed(monster varchar(10)) returns table(
	offspring varchar(10), 
	p1 varchar(15), 
	p2 varchar(15), 
	elemental_count integer,
	grp integer)
as $$

	declare 
		n integer;
		ee integer;

	begin

		n = 2;

		create temp table e on commit drop as
	    select * from breeding_e 
	    union all
	    select *, '1' from element
	    union all
	    select 'boss family', 
               (select min(be.element_count) 
               		from breeding_e be
                    join moves m
                      on be.offspring = m.monster
                  where m.family = 'boss');
        
        loop

		if exists (select * from pg_class where relname = 'y') then
	    	delete from y;
	    	insert into y
	    	select b.*, e1.element_count + e2.element_count as element_count
		    	from (select breeding.*
				      	from temp_b
				   		join breeding 
				   		  on temp_b.p1 = breeding.offspring) b
				join e e1
				  on b.p1 = e1.offspring
				join e e2
				  on b.p2 = e2.offspring;
			
			delete from z;
			insert into z
			select b.*, e1.element_count + e2.element_count as element_count
		    	from (select breeding.*
				      	from temp_b
				   		join breeding 
				   		  on temp_b.p2 = breeding.offspring) b
				join e e1
				  on b.p1 = e1.offspring
				join e e2
				  on b.p2 = e2.offspring;
		else
			create temp table y on commit drop as
		    select b.*, e1.element_count + e2.element_count as element_count
		        from breeding b 
		        join e e1 
		          on b.p1 = e1.offspring
		        join e e2
		          on b.p2 = e2.offspring
		      where b.offspring = $1;

		    create temp table z on commit drop as
		    select * 
		    	from y
		      where 1 = 2; 
	    end if;

	    if exists (select * from pg_class where relname = 'final') then
			delete from temp_b;
			insert into temp_b
			select y.*, n as group 
				from y
				join (select y.offspring, min(y.element_count) as element_count
					  	  from y
					   group by y.offspring) y1
			      on y.offspring = y1.offspring
			      and y.element_count = y1.element_count;			   
			insert into temp_b
			select z.*, n as group 
				from z 
				join (select z.offspring, min(z.element_count) as element_count
					  	  from z
					   group by z.offspring) z1
			      on z.offspring = z1.offspring
			      and z.element_count = z1.element_count;
			      			  
			insert into final
			select * from temp_b;

			n = n + 1;
		else
			create temp table final on commit drop as
		    select *, 1 as group from y 
			  where y.element_count = (select min(y.element_count) from y);
			
			create temp table temp_b on commit drop as
			select * from final;	
		end if;
		
		select max(element_count) into ee
			from temp_b;

			exit when ee <= 2;

		end loop;

		return query select * from final;
				      
	end;

$$
language plpgsql;


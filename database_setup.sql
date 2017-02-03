/*

	Purpose: Clean data and ready for processing.

	use cases:
		uses for a monster
		how to get a monster
		list of monsters that comprise the minimum elementss to get a monster
		list of monsters with by move
		breakdown of families used to create a given monster
*/

-- dragon warrior monsters breeding chart
create table breeding(
	offspring varchar(50),
    p1 varchar(50),
    p2 varchar(50)
);

-- copy data to breeding table
set client_encoding to 'Windows-1251';
copy breeding
	from 'directory/dragon_warrior_monsters.csv' delimiter ',' csv header;
set client_encoding to 'UTF8';

-- table for raw moves data
create table dwm_moves(
	beast varchar(100),
	bird varchar(100),
	boss varchar(100),
	bug varchar(100),
	devil varchar(100),
	dragon varchar(100),
	material varchar(100),
	plant varchar(100),
	slime varchar(100),
	zombie varchar(100)
);

-- copy raw data to moves table
set client_encoding to 'Windows-1251';
copy dwm_moves
	from 'directory/dwm_monster_and_move_list.csv' delimiter ',' csv header;
set client_encoding to 'UTF8';

-- ***** clean data *****

	-- first iteration cleaning moves table
	create table moves 
	as
	with x as(
	select *, row_number() over() as rnum
		from dwm_moves
	  where beast is not null),
	mon as(
	select *
		from x
	  where mod(rnum,2) = 1),
	mov as(
	select *
	 	from x
	  where mod(rnum,2) = 0)

	select monster,
		   family,
	       moves[1] as m1,
	       moves[2] as m2,
	       moves[3] as m3
		from
	(select monster,
		   family,
	       regexp_split_to_array(moves, ',') as moves
		from
	(select mon.beast as monster,
	       mov.beast as moves,
	       'beast' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.bird,
	       mov.bird as moves,
	       'bird' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.boss,
	       mov.boss as moves,
	       'boss' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.bug,
	       mov.bug as moves,
	       'bug' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.devil,
	       mov.devil as moves,
	       'devil' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.dragon,
	       mov.dragon as moves,
	       'dragon' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.material,
	       mov.material as moves,
	       'material' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.plant,
	       mov.plant as moves,
	       'plant' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.slime,
	       mov.slime as moves,
	       'slime' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1
	union all
	select mon.zombie,
	       mov.zombie as moves,
	       'zombie' as family
		from mon 
	 join mov
	   on mon.rnum = mov.rnum - 1) x1
	  where monster is not null) x2

	-- lower case
	update moves
		set monster = lower(monster)

	-- dracolord, mirudrass and deathmore are not distinguished by form
	update moves 
		set monster = 'deathmore1'
      where monster = 'deathmore'
        and m1 = 'TatsuCall';
    update moves 
		set monster = 'deathmore2'
      where monster = 'deathmore'
        and m1 = 'FireAir';
    update moves 
		set monster = 'deathmore3'
      where monster = 'deathmore'
        and m1 = 'Focus';
    update moves 
		set monster = 'dracolord1'
      where monster = 'dracolord'
        and m1 = 'Firebal';
    update moves 
		set monster = 'dracolord2'
      where monster = 'dracolord'
        and m1 = 'FireAir';
    update moves 
		set monster = 'mirudraas1'
      where monster = 'mirudraas'
        and m1 = 'Blaze';
    update moves 
		set monster = 'mirudraas2'
      where monster = 'mirudraas'
        and m1 = 'FireAir';

    -- view distinct monsters
    select 'moves' as table, count(distinct(monster)) as cnt 
		from moves
	union all 
	select 'breeding', count(distinct(offspring))
		from breeding

	-- breeding table has accurate names, moves table has some misspelling

		-- in moves not in breeding
		select monster
			from moves
		  where monster not in (select offspring from breeding)
	  
	    -- in breeding not in moves
	    select distinct(offspring)
			from breeding
		  where offspring not in (select monster from moves)

		-- correct spelling
		update moves
			set monster = 'madpecker'
		  where monster like 'madpecker_';
		update moves
			set monster = 'madraven'
		  where monster like 'madraven_';
		update moves
			set monster = '1eyeclown'
		  where monster like '1eyeclown_';
		update moves
			set monster = 'fairydrak'
		  where monster like 'fairydrak_';
		update moves
			set monster = 'balzak'
		  where monster = 'balzac';
		update moves
			set monster = 'jewelbag'
		  where monster like 'jewelbag_';
		update moves
			set monster = 'muddoll'
		  where monster = 'mud doll';
		update moves
			set monster = 'oniono'
		  where monster like 'oniono_';
		update moves
			set monster = 'wingslime'
		  where monster like 'wingslime_';
	
	-- add family to p1 and p2 families

		-- p1
		update breeding
			set p1 = p1 || ' family'
		  where p1 in ('beast', 'bird', 'boss', 'bug', 'devil', 'dragon', 'material', 'plant', 'slime', 'zombie')

		-- p2
		update breeding
			set p2 = p2 || ' family'
		  where p2 in ('beast', 'bird', 'boss', 'bug', 'devil', 'dragon', 'material', 'plant', 'slime', 'zombie')

	-- update slime

		update breeding 
			set  p1 = 'slime', p2 = 'slime'
		  where p1 = 'slime (monster)'
		     or p2 = 'slime (monster)';
	
	-- correct for dragon

		update breeding
			set p1 = 'dragon', p2 = 'dragon'
		where offspring = 'greatdrak'
		  and p1 = 'dragon family'
		  and p2 = 'dragon family';

	-- correct boss p1 and p2 spelling

		update breeding
			set p1 = 'deathmore3'
		  where offspring = 'darkdrium';

		update breeding
			set p2 = 'mirudraas1'
		  where offspring = 'deathmore1';

		update breeding
			set p1 = 'deathmore1'
		  where offspring = 'deathmore2';

		update breeding
			set p1 = 'deathmore2'
		  where offspring = 'deathmore3';

		update breeding
			set p1 = 'dracolord1'
		  where offspring = 'dracolord2';

		update breeding
			set p1 = 'mirudraas1'
		  where offspring = 'mirudraas2';
		
		update breeding
			set p1 = 'dracolord1'
		  where offspring = 'zoma';

	-- correcting watabou

		update breeding
			set p1 = 'n/a', p2 = 'n/a'
		  where offspring = 'watabou'

	-- add rows for dracolord2 and mirudraas2 as parents

		insert into breeding values
			('deathmore1', 'zoma', 'mirudraas2'),
			('zoma', 'dracolord2', 'sidoh');
	
	-- +5s

		update breeding 
			set p1 = p1 || ' +5', p2 = p2 || ' +5'
		  where p1 in ('slime', 'spotslime')
    		and p1 = p2

    	update breeding
    		set p1 = p1 || ' +5', p2 = p2 || ' +5'
    	  where offspring = 'greatdrak'
    	    and p1 = 'dragonkid'
    	    and p1 = p2

    -- moves data not trimmed

    	update moves
			set m1 = trim(m1), m2 = trim(m2), m3 = trim(m3)

	-- remove spaces from moves for consistency

		update moves
			set m1 = replace(m1, ' ', ''),
		        m2 = replace(m2, ' ', ''),
		        m3 = replace(m3, ' ', '')
	
	-- delete inaccurate rows

		delete from breeding 
		  where offspring = 'durran'
		    and p1 = 'goldgolem'

		delete from breeding
		  where offspring = 'jamirus'
		    and p1 = 'rainhawk'

	-- edit moves

	update moves
		set m3 = 'BeDragon'
	  where m3 = 'Bedragon';

	update moves
		set m3 = 'BeastCut'
	  where m3 = 'BestCut';

	update moves
		set m3 = 'BoltSlash'
	  where m3 = 'BoldSlash';

	update moves
		set m2 = 'BoltSlash'
	  where m2 = 'BoldSlash';

	update moves
		set m1 = 'Fireball'
	  where m1 = 'Firebal';

	update moves
		set m3 = 'GigaSlash'
	  where m3 = 'Gigaslash';

	update moves
		set m3 = 'HellBlast'
	  where m3 = 'Hellblast';

	update moves
		set m2 = 'HellBlast'
	  where m2 = 'Hellblast';

	update moves
		set m3 = 'KODance'
	  where m3 = 'KoDance';

	update moves
		set m3 = 'LureDance'
	  where m3 = 'LucreDance';

	update moves
		set m1 = 'LushLicks'
	  where m1 = 'Lushlicks';

	update moves
		set m1 = 'Lightning'
	  where m1 = 'Lighting';

	update moves
		set m3 = 'PoisonGas'
	  where m3 = 'PoisionGas';

	update moves
		set m3 = 'RainSlash'
	  where m3 = 'Rainslash';

	update moves
		set m3 = 'Barrier'
	  where m3 = 'Varrier';

	update moves
		set m3 = 'WindBeast'
	  where m3 = 'Windbeast';

	update moves
		set m1 = 'NapAttack'
	  where m1 = 'NapAttck';

	-- offspring family and p1 family don't align

	update breeding
		set p1 = p2, p2 = p1
	  where offspring = 'kingleo'
	    and p1 = 'roboster';

	delete from breeding
	  where offspring = 'metaldrak'
	    and p1 = 'andreal' 
	    and p2 = 'slimeborg';
	     
	delete from breeding
	  where offspring = 'metaldrak'
	    and p1 = 'spikerous' 
	    and p2 = 'kingslime';

	delete from breeding
	  where offspring = 'metaldrak'
	    and p1 = 'greatdrak' 
	    and p2 = 'digster';

	delete from breeding
	  where offspring = 'metaldrak'
	    and p1 = 'greatdrak' 
	    and p2 = 'skullgon';

	update breeding
		set p1 = p2, p2 = p1
	  where offspring = 'metaldrak'
	    and p1 = 'greatdrak';


-- ***** use cases *****

	-- uses for a monster
	select *
		from breeding
	  where p1 = 'skydragon'
	    or p2 = 'skydragon'
	 order by 1,2,3

		-- function
		create function monster_use(parent varchar(10)) returns table(offspring varchar(10), p1 varchar(10), p2 varchar(10))
		as 
		$$
			select *
				from breeding 
			  where p1 = $1
			    or p2 = $1
			 order by 1,2,3
		$$
		returns null on null input
		language sql immutable;

		-- execute function
		select * from monster_use('skydragon');
		
	-- how to get a monster
	select *
		from breeding
	  where offspring = 'skydragon'
	 order by 2,3;

		-- function
		create function get_monster(offspring varchar(10)) returns table(offspring varchar(10), p1 varchar(10), p2 varchar(10))
		as 
		$$
			select *
				from breeding 
			  where offspring = $1
			 order by 2,3
		$$
		returns null on null input
		language sql immutable;

	-- list of monsters by move

	create function monsters_by_move(move varchar(12)) returns table(monster varchar(10), family varchar(15))
	as
	$$
		select monster, family
			from moves
		  where lower(m1) = lower($1)
		     or lower(m2) = lower($1)
		     or lower(m3) = lower($1)
		 order by 2, 1
	$$
	returns null on null input
	language sql immutable;

	-- elemental count by monster

	    /* I'm afraid the recursive downward method won't work, because the tree is potentially endless. I need to log values for the elements in order to make this tree work. */

	    -- create elemental family table
	    create table element(
	    	family varchar(15)
		    );
		insert into element values
			('beast family'),
			('bird family'),
			('bug family'),
			('devil family'),
			('dragon family'),
			('material family'),
			('plant family'),
			('slime family'),
			('zombie family');

        -- manually building the table
        
        	-- create table
	        create table breeding_e
	        as
	        with x as
			(select *, 2 as element_count
				from breeding
			  where p1 in (select * from element)
			    and p2 in (select * from element))
			select b.offspring, min(y.element_count + z.element_count) as element_count
				from breeding b
			    join (select offspring, element_count from x
			          union all
			          select *, 1 from element)y
			      on b.p1 = y.offspring
			    join (select offspring, element_count from x
			          union all
			          select *, 1 from element
			          union all
			          select 'bigroost', 1
			          union all
			          select 'watabou', 1
			          union all
			          select 'boss family', 9)z
			      on b.p2 = z.offspring
             group by b.offspring

			-- next iterations: executed x times
			create temp table breeding_temp on commit drop
			as
			select b.offspring, min(y.element_count + z.element_count) as element_count
				from breeding b
			    join (select offspring, element_count from breeding_e
			          union all
			          select *, 1 from element)y
			      on b.p1 = y.offspring
			    join (select offspring, element_count from breeding_e
			          union all
			          select *, 1 from element
			          union all
			          select 'bigroost', 1
			          union all
			          select 'watabou', 1
			          union all
			          select 'boss family', 9)z
			      on b.p2 = z.offspring
	         group by b.offspring;
			delete from breeding_e;
			insert into breeding_e
				select * from breeding_temp;

-- ***** analyses *****

	-- average element_count by family
	select m.family, round(avg(e.element_count),1)
		from moves m, breeding_e e
	  where m.monster = e.offspring
     group by m.family
     order by 2 desc

    -- count of members by family
    select family, count(*)
		from moves
	 group by family
	 order by 2,1

	-- count of p2 by family for each family
	select o_fam, p_fam, sum(cnt)
		from
	(select m.family as o_fam, m2.family as p_fam, count(*) as cnt
		from breeding b, moves m, 
	    (select * from moves 
	     union all 
	     select family, left(family, length(family) - 7), null, null, null from element 
		 union all 
	     select 'boss family', 'boss', null, null, null) m2
	  where b.offspring = m.monster
	    and b.p2 = m2.monster
	 group by 1,2
	union all
	select m.family as o_fam, m2.family as p_fam, count(*) as cnt
		from breeding b, moves m, 
	    (select * from moves 
	     union all 
	     select family, left(family, length(family) - 7), null, null, null from element 
	     union all 
	     select 'boss family', 'boss', null, null, null) m2
	  where b.offspring = m.monster
	    and b.p1 = m2.monster
	    and m.family = 'boss'
	 group by 1,2) x
	 group by 1,2
	 order by 1,3 desc

-- ***** exporting data *****

	-- Copy tables to csv files. First allow permission in folder
	copy breeding to 'directory/breeding.csv' delimiter ',' csv header;

	copy breeding_e to 'directory/breeding_e.csv' delimiter ',' csv header;

	copy moves to 'directory/moves.csv' delimiter ',' csv header;

	copy element to 'directory/element.csv' delimiter ',' csv header;

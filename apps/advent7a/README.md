

I really liked this one. Took about 3 hours for both parts. 
I started down a path of identifying the hand types before realising that we just needed a sortable value for each hand.  

So my algorithm replaces each char with a number, then groups them into a list of tuples {card, count} ( thanks Enum.group_by). sorts them and then we only need to look at the first 2 results e.g five of a kinds
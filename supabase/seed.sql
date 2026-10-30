-- Tribe Green: 40 catalogue products
-- Generated from the supplied JSON.
-- Descriptions are blank because the source JSON did not include descriptions.
-- image_url uses temporary placeholder images; replace these URLs with real product photos later.

begin;

create unique index if not exists products_slug_uidx on public.products (slug);

insert into public.products (
  name,
  slug,
  category,
  min_price,
  max_price,
  description,
  image_url,
  occasions,
  customisations,
  is_active,
  sort_order
)
values
  ('Copper Water Bottle', 'copper-water-bottle', 'Drinkware', 450, 650, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Copper+Water+Bottle', ARRAY['Employee Onboarding', 'Corporate Diwali Gifting', 'New Year Gifts', 'Employee Recognition']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 1),
  ('Ceramic Mug Set', 'ceramic-mug-set', 'Drinkware', 350, 550, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Ceramic+Mug+Set', ARRAY['Employee Onboarding', 'Client and Vendor Gifting', 'Events and Trade Shows']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 2),
  ('Branded Hoodie', 'branded-hoodie', 'Apparel', 900, 1400, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Branded+Hoodie', ARRAY['Employee Onboarding', 'Employee Recognition', 'Events and Trade Shows']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 3),
  ('Polo T-shirt', 'polo-t-shirt', 'Apparel', 400, 700, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Polo+T-shirt', ARRAY['Employee Onboarding', 'Events and Trade Shows', 'Employee Recognition']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 4),
  ('Laptop Backpack', 'laptop-backpack', 'Work Essentials', 1200, 1800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Laptop+Backpack', ARRAY['Employee Onboarding', 'New Year Gifts', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 5),
  ('Notebook and Pen Set', 'notebook-and-pen-set', 'Work Essentials', 250, 450, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Notebook+and+Pen+Set', ARRAY['Employee Onboarding', 'Events and Trade Shows', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 6),
  ('Desk Organiser Set', 'desk-organiser-set', 'Work Essentials', 800, 1300, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Desk+Organiser+Set', ARRAY['Employee Recognition', 'New Year Gifts', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 7),
  ('Wellness Hamper', 'wellness-hamper', 'Wellness', 2500, 3800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Wellness+Hamper', ARRAY['Corporate Diwali Gifting', 'New Year Gifts', 'Employee Recognition']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 8),
  ('Stainless Steel Travel Mug', 'stainless-steel-travel-mug', 'Drinkware', 450, 750, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Stainless+Steel+Travel+Mug', ARRAY['Employee Onboarding', 'Client and Vendor Gifting', 'Events and Trade Shows']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 9),
  ('Insulated Coffee Tumbler', 'insulated-coffee-tumbler', 'Drinkware', 650, 950, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Insulated+Coffee+Tumbler', ARRAY['Employee Recognition', 'New Year Gifts']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 10),
  ('Bamboo Water Bottle', 'bamboo-water-bottle', 'Drinkware', 550, 850, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Bamboo+Water+Bottle', ARRAY['Employee Onboarding', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing', 'Laser engraving']::text[], true, 11),
  ('Premium Glass Bottle', 'premium-glass-bottle', 'Drinkware', 350, 600, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Glass+Bottle', ARRAY['Events and Trade Shows', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing']::text[], true, 12),
  ('Ceramic Coffee Cup', 'ceramic-coffee-cup', 'Drinkware', 250, 450, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Ceramic+Coffee+Cup', ARRAY['Employee Onboarding', 'New Year Gifts']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 13),
  ('Premium Copper Bottle Set', 'premium-copper-bottle-set', 'Drinkware', 900, 1400, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Copper+Bottle+Set', ARRAY['Corporate Diwali Gifting', 'Client and Vendor Gifting']::text[], ARRAY['Laser engraving', 'Name personalisation']::text[], true, 14),
  ('Smart Temperature Bottle', 'smart-temperature-bottle', 'Drinkware', 1200, 1800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Smart+Temperature+Bottle', ARRAY['Employee Recognition', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing']::text[], true, 15),
  ('Sports Sipper Bottle', 'sports-sipper-bottle', 'Drinkware', 300, 550, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Sports+Sipper+Bottle', ARRAY['Events and Trade Shows', 'Employee Onboarding']::text[], ARRAY['Logo printing']::text[], true, 16),
  ('Corporate Round Neck T-shirt', 'corporate-round-neck-t-shirt', 'Apparel', 300, 500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Corporate+Round+Neck+T-shirt', ARRAY['Events and Trade Shows', 'Employee Onboarding']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 17),
  ('Premium Corporate Jacket', 'premium-corporate-jacket', 'Apparel', 1500, 2500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Corporate+Jacket', ARRAY['Employee Recognition', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 18),
  ('Custom Baseball Cap', 'custom-baseball-cap', 'Apparel', 250, 450, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Custom+Baseball+Cap', ARRAY['Events and Trade Shows', 'New Year Gifts']::text[], ARRAY['Logo printing']::text[], true, 19),
  ('Premium Cotton Shirt', 'premium-cotton-shirt', 'Apparel', 800, 1300, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Cotton+Shirt', ARRAY['Employee Recognition', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 20),
  ('Corporate Sweatshirt', 'corporate-sweatshirt', 'Apparel', 900, 1500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Corporate+Sweatshirt', ARRAY['Employee Onboarding', 'Employee Recognition']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 21),
  ('Eco-friendly Tote Bag', 'eco-friendly-tote-bag', 'Apparel', 150, 350, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Eco-friendly+Tote+Bag', ARRAY['Events and Trade Shows', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing']::text[], true, 22),
  ('Premium Corporate Polo', 'premium-corporate-polo', 'Apparel', 650, 1000, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Corporate+Polo', ARRAY['Employee Onboarding', 'Employee Recognition']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 23),
  ('Custom Denim Jacket', 'custom-denim-jacket', 'Apparel', 1800, 2800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Custom+Denim+Jacket', ARRAY['Employee Recognition', 'New Year Gifts']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 24),
  ('Executive Laptop Sleeve', 'executive-laptop-sleeve', 'Work Essentials', 500, 900, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Executive+Laptop+Sleeve', ARRAY['Employee Onboarding', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 25),
  ('Wireless Charging Pad', 'wireless-charging-pad', 'Work Essentials', 700, 1200, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Wireless+Charging+Pad', ARRAY['Employee Recognition', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing']::text[], true, 26),
  ('Executive Diary', 'executive-diary', 'Work Essentials', 350, 650, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Executive+Diary', ARRAY['New Year Gifts', 'Employee Onboarding']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 27),
  ('Desk Calendar', 'desk-calendar', 'Work Essentials', 180, 350, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Desk+Calendar', ARRAY['New Year Gifts', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing']::text[], true, 28),
  ('Executive Pen Set', 'executive-pen-set', 'Work Essentials', 450, 850, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Executive+Pen+Set', ARRAY['Client and Vendor Gifting', 'Employee Recognition']::text[], ARRAY['Laser engraving', 'Name personalisation']::text[], true, 29),
  ('Wireless Bluetooth Mouse', 'wireless-bluetooth-mouse', 'Work Essentials', 550, 950, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Wireless+Bluetooth+Mouse', ARRAY['Employee Onboarding', 'Employee Recognition']::text[], ARRAY['Logo printing']::text[], true, 30),
  ('Laptop Stand', 'laptop-stand', 'Work Essentials', 800, 1400, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Laptop+Stand', ARRAY['Employee Onboarding', 'Employee Recognition']::text[], ARRAY['Logo printing']::text[], true, 31),
  ('Premium Tech Organiser', 'premium-tech-organiser', 'Work Essentials', 650, 1100, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Tech+Organiser', ARRAY['Client and Vendor Gifting', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 32),
  ('Premium Wellness Box', 'premium-wellness-box', 'Wellness', 1500, 2500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Wellness+Box', ARRAY['Employee Recognition', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 33),
  ('Organic Tea Gift Box', 'organic-tea-gift-box', 'Wellness', 700, 1200, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Organic+Tea+Gift+Box', ARRAY['New Year Gifts', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing']::text[], true, 34),
  ('Aromatherapy Gift Set', 'aromatherapy-gift-set', 'Wellness', 900, 1500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Aromatherapy+Gift+Set', ARRAY['Employee Recognition', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing']::text[], true, 35),
  ('Yoga Wellness Kit', 'yoga-wellness-kit', 'Wellness', 1200, 2000, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Yoga+Wellness+Kit', ARRAY['Employee Onboarding', 'Employee Recognition']::text[], ARRAY['Logo printing']::text[], true, 36),
  ('Healthy Snack Hamper', 'healthy-snack-hamper', 'Wellness', 600, 1000, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Healthy+Snack+Hamper', ARRAY['Employee Onboarding', 'New Year Gifts']::text[], ARRAY['Logo printing']::text[], true, 37),
  ('Premium Spa Gift Box', 'premium-spa-gift-box', 'Wellness', 1800, 2800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Premium+Spa+Gift+Box', ARRAY['Employee Recognition', 'Corporate Diwali Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 38),
  ('Fitness Essentials Kit', 'fitness-essentials-kit', 'Wellness', 1000, 1800, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Fitness+Essentials+Kit', ARRAY['Employee Onboarding', 'Events and Trade Shows']::text[], ARRAY['Logo printing']::text[], true, 39),
  ('Eco Wellness Hamper', 'eco-wellness-hamper', 'Wellness', 2200, 3500, '', 'https://placehold.co/600x600/F5F5F0/245C45.png?text=Eco+Wellness+Hamper', ARRAY['Corporate Diwali Gifting', 'Client and Vendor Gifting']::text[], ARRAY['Logo printing', 'Name personalisation']::text[], true, 40)
on conflict (slug) do update set
  name = excluded.name,
  category = excluded.category,
  min_price = excluded.min_price,
  max_price = excluded.max_price,
  occasions = excluded.occasions,
  customisations = excluded.customisations,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

commit;

-- Verify the seeded catalogue:
select category, count(*) as product_count
from public.products
group by category
order by category;

select count(*) as total_active_products
from public.products
where is_active = true;

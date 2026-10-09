# Business memo: Fixing delivery to protect satisfaction and repeat business

**To:** Olist operations and growth leadership (hypothetical audience for a portfolio project)
**From:** Piyush, data analyst
**Data:** about 96,000 delivered orders, Jan 2017 to Aug 2018

## Summary

Late deliveries are a small share of orders but cause a large share of customer dissatisfaction, and they are linked to fewer repeat purchases. Rio de Janeiro is the highest-impact place to improve. Separately, almost no customers return (about 3%), so growth depends entirely on acquiring new customers.

## What the data shows

- **8.1% of orders arrive late, but they make up 33.8% of all 1-2 star reviews.** Late orders average 2.57 stars versus 4.29 on time.
- **The damage grows with delay.** On time: 4.29 stars. 1-3 days late: 3.77. 4-7 days late: 2.32. 8+ days late: 1.73. The steepest drop is between 1-3 and 4-7 days late.
- **Customers whose first order was late reorder less:** 3.04% versus 4.30% (p = 0.0013, 95% CI for the gap: -1.9 to -0.6 percentage points).
- **Late rates are highest in the north and northeast** (MA 19.7%, CE 15.3%, BA 14.0%), but **RJ has the biggest impact** because of volume: 1,664 late orders at a 13.5% late rate, versus 5.9% in SP.
- **Only about 3% of customers ever order again,** and monthly cohort retention stays around 0.2% to 0.7%.
- **Order value is stable** (R$146 to R$170 per month), so past revenue growth came from more orders, not larger baskets.

## Recommendations

1. **Prioritize Rio de Janeiro for delivery improvement.** Bringing RJ's late rate from 13.5% down to SP's 5.9% would remove roughly 930 late orders, about 12% of all late orders.
2. **Act before an order becomes 4+ days late.** Satisfaction collapses after about three days of delay, so proactive tracking updates, or a small voucher for orders at risk of passing that point, should protect scores.
3. **Review delivery estimates in MA, CE and BA.** Persistently high late rates suggest estimates are too optimistic there. Test more realistic estimates, since lateness is judged against the promised date.
4. **Test a first-purchase retention program.** Run a controlled test (for example a post-delivery voucher for first-time buyers) with 90-day repeat purchase as the main metric. At a base rate of about 4%, detecting a 1-point lift needs roughly 7,000 customers per group at 80% power (to be confirmed in a formal test plan).
5. **Plan experiments realistically.** Order value is noisy, so a test of a 5% lift in average order value needs about 11,780 orders per group (about 7,100 with order values capped at the 99th percentile). That is roughly 2 to 4 months of traffic at 2018 volume, so test bigger changes or use more traffic.

## Caveats

- Findings are **observational**: late orders may also differ by region, product or seller, so the data shows association, not proof of cause.
- Ratings come only from customers who chose to leave a review.
- The A/B test work in this project is a **design and simulation**, not a real experiment.
- Data covers 2016 to 2018 and may not reflect current operations.

## Suggested next analyses

- Check whether distance between seller and customer explains the high late rates in the north and northeast.
- Identify sellers and carriers that drive late orders in RJ.
- Test whether late first deliveries affect repeat purchases after controlling for region and product category.

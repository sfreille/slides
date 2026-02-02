# Sed script to update image references in QMD files
# Usage: sed -f update_qmd_refs.sed -i filename.qmd

# Background
s/fig-00-background\.png/bg-world-trade-night-lights.png/g

# Unit 01
s/fig-01-001\.png/fig-quote-trump-globalization-middle-class.png/g
s/fig-01-002\.png/fig-quote-kirchner-imports-festival.png/g
s/fig-01-003\.png/fig-quote-macri-export-tax-perverse.png/g
s/fig-01-004\.png/fig-quote-fernandez-export-tax-prices.png/g
s/fig-01-005\.png/fig-poll-gallup-nafta-american-views.png/g
s/fig-01-006\.png/fig-poll-latam-trade-support-radial.png/g
s/fig-01-007\.png/fig-poll-latam-trade-question-framing.png/g
s/fig-01-008\.png/fig-poll-igm-economists-trade-consensus.png/g
s/fig-01-009\.png/fig-chart-exports-gdp-share-historical.png/g
s/fig-01-010\.png/fig-map-trade-openness-world-2020.png/g
s/fig-01-011\.png/fig-chart-services-exports-share-historical.png/g
s/fig-01-012\.png/fig-treemap-india-exports-composition.png/g
s/fig-01-013\.png/fig-treemap-panama-exports-composition.png/g
s/fig-01-014\.png/fig-chart-world-external-assets-gdp.png/g
s/fig-01-015\.png/fig-chart-financial-integration-historical.png/g
s/fig-01-016\.png/fig-chart-us-immigrants-share-historical.png/g
s/fig-01-017\.png/fig-chart-migration-flows-historical.png/g
s/fig-01-018\.png/fig-chart-remittances-global-trend.png/g
s/fig-01-019\.png/fig-chart-regional-tariffs-postwar.png/g
s/fig-01-020\.png/fig-chart-us-tariffs-historical-annotated.png/g
s/fig-01-021\.png/fig-chart-world-tariffs-historical.png/g
s/fig-01-022\.png/fig-scatter-eu-us-trade-gdp-share.png/g
s/fig-01-023\.png/fig-scatter-eu-us-trade-gdp-nafta.png/g
s/fig-01-024\.png/fig-map-eu-trade-barriers-world.png/g
s/fig-01-025\.png/fig-chart-latam-trade-liberalization-kof.png/g
s/fig-01-026\.png/fig-map-us-canada-provinces-states.png/g
s/fig-01-027\.png/fig-chart-trade-network-evolution.png/g

# Unit 02
s/fig-02-001\.png/fig-diagram-ppf-opportunity-cost-home.png/g
s/fig-02-002\.png/fig-diagram-ppf-opportunity-cost-foreign.png/g
s/fig-02-003\.png/fig-diagram-relative-supply-demand-equilibrium.png/g
s/fig-02-004\.png/fig-diagram-ppf-trade-gains-two-countries.png/g
s/fig-02-005\.png/fig-scatter-productivity-exports-us-uk.png/g
s/fig-02-006\.png/fig-map-us-county-exports-retaliation.png/g
s/fig-02-007\.png/fig-diagram-wages-productivity-relation.png/g
s/fig-02-008\.png/fig-diagram-relative-wages-determination.png/g
s/fig-02-009\.png/fig-diagram-non-traded-goods-model.png/g
s/fig-02-010\.png/fig-diagram-specific-factors-ppf-derivation.png/g
s/fig-02-011\.png/fig-diagram-labor-allocation-two-sectors.png/g
s/fig-02-012\.png/fig-diagram-wage-determination-specific-factors.png/g
s/fig-02-013\.png/fig-diagram-price-change-wage-effect.png/g
s/fig-02-014\.png/fig-diagram-trade-income-distribution.png/g
s/fig-02-015\.png/fig-diagram-relative-supply-demand-manufactures.png/g
s/fig-02-016\.png/fig-diagram-trade-expansion-effect.png/g
s/fig-02-017\.png/fig-diagram-terms-of-trade-change.png/g
s/fig-02-018\.png/fig-diagram-welfare-effects-trade.png/g
s/fig-02-019\.png/fig-diagram-factor-price-equalization.png/g

# Unit 03
s/fig-03-001\.png/fig-diagram-ppf-labor-constraint-slope.png/g
s/fig-03-002\.png/fig-diagram-ppf-capital-constraint.png/g
s/fig-03-003\.png/fig-diagram-ppf-two-factor-derivation.png/g
s/fig-03-004\.png/fig-diagram-goods-prices-factor-prices.png/g
s/fig-03-005\.png/fig-diagram-factor-intensity-wage-rental.png/g
s/fig-03-006\.png/fig-diagram-stolper-samuelson-theorem.png/g
s/fig-03-007\.png/fig-diagram-rybczynski-theorem.png/g
s/fig-03-008\.png/fig-diagram-ho-relative-supply.png/g
s/fig-03-009\.png/fig-diagram-factor-price-equalization-proof.png/g

# Unit 04
s/fig-04-001\.png/fig-diagram-isovalue-lines-production.png/g
s/fig-04-002\.png/fig-diagram-consumption-production-choice.png/g
s/fig-04-003\.png/fig-diagram-terms-of-trade-welfare.png/g
s/fig-04-004\.png/fig-diagram-growth-terms-of-trade.png/g
s/fig-04-005\.png/fig-diagram-immiserizing-growth.png/g
s/fig-04-005a\.png/fig-diagram-immiserizing-growth-alt.png/g
s/fig-04-006\.png/fig-diagram-tariff-effects-small-country.png/g
s/fig-04-007\.png/fig-diagram-tariff-effects-large-country.png/g
s/fig-04-008\.png/fig-diagram-optimal-tariff.png/g

# Unit 05
s/fig-05-001\.png/fig-diagram-monopoly-marginal-cost-demand.png/g
s/fig-05-002\.png/fig-diagram-monopolistic-competition-equilibrium.png/g
s/fig-05-003\.png/fig-diagram-average-cost-pricing.png/g
s/fig-05-004\.png/fig-diagram-number-firms-equilibrium.png/g
s/fig-05-005\.png/fig-diagram-market-size-variety.png/g
s/fig-05-006\.png/fig-diagram-intra-industry-trade.png/g
s/fig-05-007\.png/fig-diagram-trade-integration-effects.png/g
s/fig-05-008\.png/fig-diagram-external-economies-scale.png/g
s/fig-05-009\.png/fig-diagram-learning-curve.png/g
s/fig-05-010\.png/fig-diagram-market-size-firms-equilibrium.png/g
s/fig-05-011\.png/fig-diagram-dumping-price-discrimination.png/g
s/fig-05-012\.png/fig-diagram-reciprocal-dumping.png/g
s/fig-05-013\.png/fig-diagram-firm-heterogeneity.png/g
s/fig-05-014\.png/fig-diagram-melitz-model-selection.png/g
s/fig-05-015\.png/fig-diagram-trade-firm-productivity.png/g
s/fig-05-016\.png/fig-diagram-gravity-model-derivation.png/g
s/fig-05-017\.png/fig-diagram-trade-costs-distance.png/g
s/fig-05-018\.png/fig-diagram-border-effects.png/g

# Unit 06
s/fig-06-001\.png/fig-table-interest-rate-parity-examples.png/g
s/fig-06-002\.png/fig-diagram-forex-market-equilibrium.png/g
s/fig-06-003\.png/fig-diagram-interest-rate-exchange-rate.png/g
s/fig-06-004\.png/fig-diagram-money-supply-exchange-rate.png/g
s/fig-06-005\.png/fig-diagram-purchasing-power-parity.png/g
s/fig-06-006\.png/fig-diagram-overshooting-model.png/g

# Video
s/vid-01-001\.mp4/vid-trade-globalization-intro.mp4/g

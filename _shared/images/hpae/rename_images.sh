#!/bin/bash
# Rename script for HPAE course images
# Historia del Pensamiento y Análisis Económico
# Pattern: fig-{type}-{description}.{ext}

cd "$(dirname "$0")"

# Backgrounds - move to backgrounds folder
mv "background-001.png" "../backgrounds/bg-hpae-industrial-revolution.png" 2>/dev/null
mv "background-002.png" "../backgrounds/bg-hpae-02.png" 2>/dev/null

# Concurso (competition) images
mv "concurso-001.png" "fig-chart-jel-codes-top5-journals.png" 2>/dev/null
mv "concurso-002.png" "fig-chart-concurso-02.png" 2>/dev/null
mv "concurso-003.png" "fig-chart-concurso-03.png" 2>/dev/null
mv "concurso-004.png" "fig-chart-concurso-04.png" 2>/dev/null
mv "concurso-005.jpg" "fig-photo-concurso-05.jpg" 2>/dev/null
mv "concurso-006.png" "fig-chart-concurso-06.png" 2>/dev/null
mv "concurso-007.png" "fig-chart-concurso-07.png" 2>/dev/null
mv "concurso-008.png" "fig-chart-concurso-08.png" 2>/dev/null
mv "concurso-009.jpg" "fig-photo-concurso-09.jpg" 2>/dev/null

# Unit 00 - Introduction
mv "fig-00-001.png" "fig-diagram-intro-economic-thought.png" 2>/dev/null

# Unit 01 - Why study history of economic thought
mv "fig-01-001.png" "fig-quote-ederer-milanovic-classics.png" 2>/dev/null
mv "fig-01-002.png" "fig-quote-intro-02.png" 2>/dev/null
mv "fig-01-003.png" "fig-diagram-intro-03.png" 2>/dev/null
mv "fig-01-004.png" "fig-diagram-intro-04.png" 2>/dev/null
mv "fig-01-005.png" "fig-diagram-intro-05.png" 2>/dev/null
mv "fig-01-006.png" "fig-diagram-intro-06.png" 2>/dev/null
mv "fig-01-007.png" "fig-diagram-intro-07.png" 2>/dev/null

# Unit 02 - Ancient/Pre-classical thought
mv "fig-02-000.png" "fig-diagram-ancient-overview.png" 2>/dev/null
mv "fig-02-001.png" "fig-table-chinese-economic-thought-articles.png" 2>/dev/null
mv "fig-02-002.png" "fig-diagram-ancient-02.png" 2>/dev/null
mv "fig-02-003.png" "fig-diagram-ancient-03.png" 2>/dev/null
mv "fig-02-004.png" "fig-diagram-ancient-04.png" 2>/dev/null
mv "fig-02-005.png" "fig-diagram-ancient-05.png" 2>/dev/null
mv "fig-02-006.png" "fig-diagram-ancient-06.png" 2>/dev/null
mv "fig-02-007.png" "fig-diagram-ancient-07.png" 2>/dev/null
mv "fig-02-008.png" "fig-diagram-ancient-08.png" 2>/dev/null
mv "fig-02-009.png" "fig-diagram-ancient-09.png" 2>/dev/null
mv "fig-02-010.png" "fig-diagram-ancient-10.png" 2>/dev/null
# Already descriptive
# fig-02-plato-division-of-labour-01.png - keep
# fig-02-plato-division-of-labour-02.png - keep

# Unit 03 - Medieval/Scholastic thought
mv "fig-03-000.png" "fig-diagram-medieval-overview.png" 2>/dev/null
mv "fig-03-001.png" "fig-map-trade-routes-before-columbus.png" 2>/dev/null
mv "fig-03-002.png" "fig-diagram-medieval-02.png" 2>/dev/null
mv "fig-03-003.png" "fig-diagram-medieval-03.png" 2>/dev/null
mv "fig-03-004.png" "fig-diagram-medieval-04.png" 2>/dev/null
mv "fig-03-005.png" "fig-diagram-medieval-05.png" 2>/dev/null
mv "fig-03-006.png" "fig-diagram-medieval-06.png" 2>/dev/null
mv "fig-03-007.png" "fig-diagram-medieval-07.png" 2>/dev/null

# Unit 04 - Adam Smith / Classical Economics
mv "fig-04-001.png" "fig-doc-anne-greene-1651.png" 2>/dev/null
mv "fig-04-002.png" "fig-diagram-smith-02.png" 2>/dev/null
mv "fig-04-003.png" "fig-diagram-smith-03.png" 2>/dev/null
mv "fig-04-004.png" "fig-diagram-smith-04.png" 2>/dev/null
mv "fig-04-005.png" "fig-diagram-smith-05.png" 2>/dev/null
mv "fig-04-006.png" "fig-diagram-smith-06.png" 2>/dev/null
mv "fig-04-007.png" "fig-diagram-smith-07.png" 2>/dev/null
mv "fig-04-008.png" "fig-diagram-smith-08.png" 2>/dev/null
mv "fig-04-009.png" "fig-diagram-smith-09.png" 2>/dev/null
mv "fig-04-010.png" "fig-diagram-smith-10.png" 2>/dev/null
mv "fig-04-011.png" "fig-diagram-smith-11.png" 2>/dev/null
mv "fig-04-012.png" "fig-diagram-smith-12.png" 2>/dev/null
mv "fig-04-013.png" "fig-diagram-smith-13.png" 2>/dev/null
mv "fig-04-014.png" "fig-diagram-smith-14.png" 2>/dev/null
# Already descriptive
# fig-04-adam-smith-growth.png - keep
# fig-04-adam-smith-loop.png - keep

# Unit 05 - Ricardo / Classical Economics continued
mv "fig-05-001.png" "fig-text-fourier-climate.png" 2>/dev/null
mv "fig-05-002.png" "fig-diagram-ricardo-02.png" 2>/dev/null
mv "fig-05-003.png" "fig-diagram-ricardo-03.png" 2>/dev/null
mv "fig-05-004.png" "fig-diagram-ricardo-04.png" 2>/dev/null
mv "fig-05-005.png" "fig-diagram-ricardo-05.png" 2>/dev/null
mv "fig-05-006.png" "fig-diagram-ricardo-06.png" 2>/dev/null
mv "fig-05-007.png" "fig-diagram-ricardo-07.png" 2>/dev/null
mv "fig-05-008.png" "fig-diagram-ricardo-08.png" 2>/dev/null
mv "fig-05-009.png" "fig-diagram-ricardo-09.png" 2>/dev/null
mv "fig-05-add-001.png" "fig-diagram-ricardo-additional.png" 2>/dev/null

# Unit 06 - Cournot / Mathematical Economics
mv "fig-06-001.png" "fig-quote-cournot-smith-say-ricardo.png" 2>/dev/null
mv "fig-06-002.png" "fig-diagram-cournot-02.png" 2>/dev/null
mv "fig-06-003.png" "fig-diagram-cournot-03.png" 2>/dev/null
mv "fig-06-004.png" "fig-diagram-cournot-04.png" 2>/dev/null
mv "fig-06-005.png" "fig-diagram-cournot-05.png" 2>/dev/null
mv "fig-06-006.png" "fig-diagram-cournot-06.png" 2>/dev/null
mv "fig-06-007.png" "fig-diagram-cournot-07.png" 2>/dev/null
mv "fig-06-008.png" "fig-diagram-cournot-08.png" 2>/dev/null
mv "fig-06-009.png" "fig-diagram-cournot-09.png" 2>/dev/null
mv "fig-06-010.png" "fig-diagram-cournot-10.png" 2>/dev/null

# Unit 08 - Later developments
mv "fig-08-001.png" "fig-diagram-later-developments.png" 2>/dev/null

# Unit 09 - Modern economics / 20th century
mv "fig-09-001.png" "fig-chart-inflation-us-uk-since-1900.png" 2>/dev/null
mv "fig-09-002.jpg" "fig-photo-modern-02.jpg" 2>/dev/null
mv "fig-09-003.png" "fig-diagram-modern-03.png" 2>/dev/null
mv "fig-09-004.png" "fig-diagram-modern-04.png" 2>/dev/null

echo "Rename complete!"

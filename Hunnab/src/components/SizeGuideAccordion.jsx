import { useState } from 'react';
import { AnillosSizeGuide, CollaresSizeGuide, PulserasSizeGuide } from './SizeGuides';

/** Acordeon de guia de tallas a ancho completo, fuera del grid de dos columnas. */
function SizeGuideAccordion({ categoryKey }) {
  const [open, setOpen] = useState(false);

  let content = null;
  if (categoryKey === 'anillos') content = <AnillosSizeGuide />;
  else if (categoryKey.startsWith('pulseras')) content = <PulserasSizeGuide />;
  else if (categoryKey.startsWith('collares')) content = <CollaresSizeGuide />;

  if (!content) return null;

  return (
    <div className="sg-accordion">
      <div className="accordion-item">
        <button
          className="accordion-header"
          type="button"
          aria-expanded={open ? 'true' : 'false'}
          onClick={() => setOpen(!open)}
        >
          <span>Guia de tamaños</span>
          <span className="accordion-icon" aria-hidden="true" />
        </button>
        <div className={`accordion-panel ${open ? 'is-open' : ''}`}>
          <div className="accordion-panel-inner">
            {content}
          </div>
        </div>
      </div>
    </div>
  );
}

export default SizeGuideAccordion;

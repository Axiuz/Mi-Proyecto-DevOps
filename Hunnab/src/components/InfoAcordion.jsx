import { useState } from 'react';

/** Acordeon con informacion extendida de la categoria seleccionada. */
function InfoAccordion({ app, category, categoryKey, extraTabs = [] }) {
  // Estado y datos de entrada
  const [openId, setOpenId] = useState(null);
  const tabs = [...app.catalog.getCategoryInfoTabs(category, categoryKey), ...extraTabs];

  // Render
  return (
    <div className="accordion">
      {tabs.map((tab) => {
        const expanded = openId === tab.id;
        return (
          <div className="accordion-item" key={tab.id}>
            <button
              className="accordion-header"
              type="button"
              data-accordion={tab.id}
              aria-expanded={expanded ? 'true' : 'false'}
              aria-controls={`accordion-panel-${tab.id}`}
              onClick={() => setOpenId(expanded ? null : tab.id)}
            >
              <span>{tab.label}</span>
              <span className="accordion-icon" aria-hidden="true" />
            </button>
            <div
              id={`accordion-panel-${tab.id}`}
              className={`accordion-panel ${expanded ? 'is-open' : ''}`}
              data-panel={tab.id}
            >
              <div className="accordion-panel-inner">
                {typeof tab.content === 'string' ? <p>{tab.content}</p> : tab.content}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default InfoAccordion;

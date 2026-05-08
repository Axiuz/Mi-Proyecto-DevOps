import InfoAccordion from '../components/InfoAcordion';
import SizeGuideAccordion from '../components/SizeGuideAccordion';

/** Muestra una categoria, su contenido informativo y sus productos. */
function CategoryPage({ app, categoryKey }) {
  // Datos base de categoria
  const category = app.catalog.getCategory(categoryKey);

  // Estado de error (categoria no encontrada)
  if (!category) {
    return (
      <div className="hero">
        <h1>No encontrado</h1>
        <p>
          La ruta no existe. Vuelve al <a href="#/">inicio</a>.
        </p>
      </div>
    );
  }

  // Datos derivados para render
  const categoryProducts = app.catalog.getCategoryProducts(categoryKey);

  // Si la categoria tiene subdivision por genero, se agrega como item extra del acordeon
  const genderTab = category.tabs?.length
    ? {
        id: 'por-genero',
        label: 'Por género',
        content: (
          <div className="gender-links">
            {category.tabs.map((tab) => (
              <a key={tab.id} className="gender-link" href={`#/${categoryKey}/${tab.id}`}>
                {tab.label}
              </a>
            ))}
          </div>
        ),
      }
    : null;

  // Render
  return (
    <>
      <div className="crumb">Inicio / {category.title}</div>
      <div className="cat-card">
        <div className="cat-card__grid">
          <div>
            <h1 style={{ margin: '0 0 6px' }}>{category.title}</h1>
            <p style={{ margin: 0, color: 'var(--muted)' }}>{category.desc}</p>
            <InfoAccordion
              app={app}
              category={category}
              categoryKey={categoryKey}
              extraTabs={genderTab ? [genderTab] : []}
            />
          </div>
          <div className="shot big" style={{ margin: 0 }}>
            <img src={app.images.normalize(category.heroImg)} alt={category.title} />
          </div>
        </div>
        <SizeGuideAccordion categoryKey={categoryKey} />
      </div>

      <div className="grid">
        {categoryProducts.map(({ id, product }) => {
          const image = app.images.normalize(product.img);
          const hover = app.images.normalize(product.imgHover || product.img);
          return (
            <a key={id} className="card" href={`#/p/${id}`}>
              <div className="img-swap">
                <img className="base" src={image} alt={product.title} />
                <img className="hover" src={hover} alt={product.title} />
              </div>
              <div className="card__body">
                <strong>{product.title}</strong>
                <span>{app.currency.formatMXN(product.price)}</span>
                <span className={`card-stock ${product.stock <= 0 ? 'is-out' : ''}`}>
                  {product.stock <= 0 ? 'Sin stock' : `Stock: ${product.stock}`}
                </span>
              </div>
            </a>
          );
        })}
      </div>
    </>
  );
}

export default CategoryPage;

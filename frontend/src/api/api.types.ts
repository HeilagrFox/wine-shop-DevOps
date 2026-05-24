export type UUID = string & { readonly __brand: 'UUID' };

export type WineColor = "red" | "white";
export type WineAcidity = "dry" | "semi-dry" | "semi-sweet" | "sweet";

export type Wine = {
  id: UUID;
  name: string;
  price: number;
  description?: string;
  color?: WineColor;
  acidity?: WineAcidity;
  country?: string;
};

export type CartWine = Wine & {
  count: number;
};

export type SearchWinesRequest = {
  query: string;
  priceMin: number;
  priceMax: number;
};

export type SearchWinesResponse = {
  summary: string;
  wines: Wine[];
};

export type GetCartWinesResponse = {
  wines: CartWine[];
};

export type UpdateCartWineCountRequest = {
  count: number;
};

export type UpdateCartWineCountResponse = {
  updatedCount: number;
};

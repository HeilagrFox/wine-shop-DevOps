import axios from "axios";
import type {
  UUID,
  SearchWinesRequest,
  SearchWinesResponse,
  GetCartWinesResponse,
  UpdateCartWineCountRequest,
  UpdateCartWineCountResponse,
} from "./api.types";

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000",
});


export const searchWines = async (
  payload: SearchWinesRequest,
): Promise<SearchWinesResponse> => {
  const { data } = await api.post<SearchWinesResponse>("/search/wines", payload);
  return data;

};


export const addWineToCart = async (
  wineId: UUID,
): Promise<void> => {
  await api.post<void>(`/cart/wines/${wineId}`);
};


export const getCartWines = async (): Promise<GetCartWinesResponse> => {
  const { data } = await api.get<GetCartWinesResponse>("/cart/wines");
  return data;
};

export const updateCartWineCount = async (
  wineId: UUID,
  payload: UpdateCartWineCountRequest,
): Promise<UpdateCartWineCountResponse> => {
  const { data } = await api.put<UpdateCartWineCountResponse>(`/cart/wines/${wineId}`, payload);
  return data;
};

export const deleteWineFromCart = async (
  wineId: UUID,
): Promise<void> => {
  await api.delete<void>(`/cart/wines/${wineId}`);
};

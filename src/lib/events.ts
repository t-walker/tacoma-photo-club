import eventsData from "../data/events.json";
import { getEventFlier } from "./images";

export type EventStatus = "next" | "upcoming" | "past";

export type ClubEvent = {
  id: string;
  title: string;
  location: string;
  /** ISO 8601, ideally with a -07:00/-08:00 offset so it is unambiguous. */
  date: string;
  description: string;
  flier?: string;
  url?: string;
};

export type DecoratedEvent = ClubEvent & {
  status: EventStatus;
  flierImage?: ImageMetadata;
  dateLabel: string;
  timeLabel: string;
};

const dateFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "short",
  month: "short",
  day: "numeric",
  year: "numeric",
  timeZone: "America/Los_Angeles",
});

const timeFormatter = new Intl.DateTimeFormat("en-US", {
  hour: "numeric",
  minute: "2-digit",
  timeZone: "America/Los_Angeles",
});

/**
 * Events sorted for display: the next one first, then the rest of the upcoming
 * run, then past events newest-first. Statuses are recomputed in the browser
 * (see events.astro) so a stale build never shows a past event as upcoming.
 */
export function getEvents(now: Date = new Date()): DecoratedEvent[] {
  const events = (eventsData as ClubEvent[]).map((event) => {
    const when = new Date(event.date);
    return {
      event,
      when,
      isPast: when.getTime() < now.getTime(),
    };
  });

  const upcoming = events
    .filter((e) => !e.isPast)
    .sort((a, b) => a.when.getTime() - b.when.getTime());
  const past = events
    .filter((e) => e.isPast)
    .sort((a, b) => b.when.getTime() - a.when.getTime());

  return [...upcoming, ...past].map(({ event, when, isPast }, index) => ({
    ...event,
    status: isPast ? "past" : index === 0 ? "next" : "upcoming",
    flierImage: getEventFlier(event.flier),
    dateLabel: Number.isNaN(when.getTime()) ? event.date : dateFormatter.format(when),
    timeLabel: Number.isNaN(when.getTime()) ? "" : timeFormatter.format(when),
  }));
}

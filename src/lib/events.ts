import eventsData from "../data/events.json";
import { getEventFlier } from "./images";

export type EventStatus = "upcoming" | "past";

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
 * Every event, newest first — upcoming and past interleave in one straight
 * reverse-chronological run. Statuses are recomputed in the browser (see
 * events.astro) so a stale build never mislabels an event.
 */
export function getEvents(now: Date = new Date()): DecoratedEvent[] {
  return (eventsData as ClubEvent[])
    .map((event) => ({ event, when: new Date(event.date) }))
    .sort((a, b) => b.when.getTime() - a.when.getTime())
    .map(({ event, when }) => ({
      ...event,
      status: when.getTime() < now.getTime() ? ("past" as const) : ("upcoming" as const),
      flierImage: getEventFlier(event.flier),
      dateLabel: Number.isNaN(when.getTime()) ? event.date : dateFormatter.format(when),
      timeLabel: Number.isNaN(when.getTime()) ? "" : timeFormatter.format(when),
    }));
}

/** The soonest upcoming event — the one that gets the featured slot. */
export function getNextEvent(events: DecoratedEvent[]): DecoratedEvent | undefined {
  const upcoming = events.filter((event) => event.status === "upcoming");
  return upcoming[upcoming.length - 1];
}

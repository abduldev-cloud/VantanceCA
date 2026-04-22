import React, { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './LandingPage.module.css';

/* ─────────────────── data ─────────────────── */
const painPoints = [
  {
    icon: '🌀',
    title: `Drowning in tasks you can't prioritize`,
    desc: 'You open your task list and instantly feel stuck. Everything looks urgent — but nothing is moving forward.',
  },
  {
    icon: '⏰',
    title: 'Deadlines sneak up on you',
    desc: `You thought you had time. Then suddenly it's the day before — and the work hasn't even started.`,
  },
  {
    icon: '🧠',
    title: 'Decision fatigue kills momentum',
    desc: `Spending 20 minutes deciding what to work on next is not a productivity strategy. It's a trap.`,
  },
  {
    icon: '📉',
    title: 'Missed goals erode your confidence',
    desc: `When weeks go by and the big things aren't done, the problem isn't effort — it's focus.`,
  },
];

const features = [
  {
    icon: '🤖',
    title: 'AI Prioritization',
    outcome: 'Never guess what to work on next.',
    desc: 'The AI analyzes deadlines, task weight, and your workload — then tells you exactly what to tackle first.',
  },
  {
    icon: '📋',
    title: 'Real-Time Task Tracking',
    outcome: 'See everything. Miss nothing.',
    desc: 'Live progress bars, status updates, and completion signals keep your work visible at all times.',
  },
  {
    icon: '🖥️',
    title: 'Clean, Focused Dashboard',
    outcome: 'Zero clutter. Total clarity.',
    desc: 'A distraction-free workspace that shows only what matters — right now, today, this week.',
  },
  {
    icon: '🔔',
    title: 'Smart Deadline Alerts',
    outcome: `Get warned before it's too late.`,
    desc: `Contextual reminders based on your workload — not just arbitrary pings that you'll ignore.`,
  },
];

const steps = [
  {
    num: '01',
    title: 'Add Your Tasks',
    desc: 'Drop in your tasks in seconds — titles, deadlines, and importance. No mandatory fields, no friction.',
  },
  {
    num: '02',
    title: 'AI Prioritizes Instantly',
    desc: 'Our engine reads your workload and reorders your list automatically. The most critical task is always at the top.',
  },
  {
    num: '03',
    title: 'Execute with Confidence',
    desc: 'Follow the AI-curated queue, hit deadlines, and finish your day knowing you worked on the right things.',
  },
];

const testimonials = [
  {
    name: 'Riya Mehta',
    role: 'Freelance UI Designer',
    avatar: 'RM',
    quote:
      'I used to start every morning paralyzed by my task list. Now the AI just tells me what to do first. I get 40% more done and my clients have noticed.',
  },
  {
    name: 'James Okonkwo',
    role: 'Founder, 3-person agency',
    avatar: 'JO',
    quote:
      `We missed two client deadlines in Q1. Since switching, we haven't missed one. The deadline alerts alone are worth it.`,
  },
  {
    name: 'Priya Nair',
    role: 'Independent Consultant',
    avatar: 'PN',
    quote:
      `The dashboard is so clean it actually makes me want to open it. That's something I never said about any other tool.`,
  },
];

/* ─────────────── component ─────────────── */
export default function LandingPage() {
  const navigate = useNavigate();
  const [scrolled, setScrolled] = useState(false);
  const [activeTestimonial, setActiveTestimonial] = useState(0);
  const heroRef = useRef(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  // Auto-rotate testimonials
  useEffect(() => {
    const id = setInterval(
      () => setActiveTestimonial((p) => (p + 1) % testimonials.length),
      4000
    );
    return () => clearInterval(id);
  }, []);

  // Intersection observer for scroll-reveal
  useEffect(() => {
    const els = document.querySelectorAll('[data-reveal]');
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            e.target.classList.add(styles.revealed);
            obs.unobserve(e.target);
          }
        });
      },
      { threshold: 0.12 }
    );
    els.forEach((el) => obs.observe(el));
    return () => obs.disconnect();
  }, []);

  const goToLogin = () => navigate('/auth/login');

  return (
    <div className={styles.page}>

      {/* ── NAV ── */}
      <nav className={`${styles.nav} ${scrolled ? styles.navScrolled : ''}`}>
        <div className={styles.navInner}>
          <div className={styles.logo}>
            <span className={styles.logoIcon}>⚡</span>
            <span className={styles.logoText}>VantanceAI</span>
          </div>
          <div className={styles.navLinks}>
            <a href="#features" className={styles.navLink}>Features</a>
            <a href="#how" className={styles.navLink}>How It Works</a>
            <a href="#testimonials" className={styles.navLink}>Reviews</a>
          </div>
          <div className={styles.navCta}>
            <button className={styles.navLoginBtn} onClick={goToLogin} id="nav-login-btn">
              Sign In
            </button>
            <button className={styles.navPrimaryBtn} onClick={goToLogin} id="nav-start-btn">
              Start Free →
            </button>
          </div>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section className={styles.hero} ref={heroRef}>
        <div className={styles.heroBg} aria-hidden="true">
          <div className={styles.heroBlobLeft} />
          <div className={styles.heroBlobRight} />
          <div className={styles.heroGrid} />
        </div>

        <div className={styles.heroContent}>
          <div className={styles.heroBadge} data-reveal>
            <span className={styles.badgeDot} />
            AI-Powered · Zero Setup · Free to Start
          </div>

          <h1 className={styles.heroHeadline} data-reveal>
            Stop Guessing What to Work On.
            <br />
            <span className={styles.heroGradient}>Let AI Decide.</span>
          </h1>

          <p className={styles.heroSubHead} data-reveal>
            VantanceAI automatically ranks your tasks by deadline, importance, and
            capacity — so you spend zero time planning and every minute executing.
          </p>

          <div className={styles.heroCtas} data-reveal>
            <button
              className={styles.primaryCta}
              onClick={goToLogin}
              id="hero-start-btn"
            >
              Start Free — No Credit Card
            </button>
            <a href="#how" className={styles.secondaryCta} id="hero-watch-btn">
              See How It Works ↓
            </a>
          </div>

          <p className={styles.heroProof} data-reveal>
            Trusted by 2,400+ freelancers &amp; small teams
          </p>
        </div>

        {/* ── Floating Dashboard Preview ── */}
        <div className={styles.heroPreview} data-reveal>
          <div className={styles.dashCard}>
            <div className={styles.dashHeader}>
              <span className={styles.dashTitle}>Today's Priority Queue</span>
              <span className={styles.dashBadge}>AI Sorted</span>
            </div>
            <div className={styles.taskList}>
              {[
                { label: 'Client proposal — Acme Corp', tag: 'URGENT', color: '#ef4444', pct: 85 },
                { label: 'Finalize invoice #042', tag: 'HIGH', color: '#f59e0b', pct: 60 },
                { label: 'Team sync deck', tag: 'MEDIUM', color: '#6366f1', pct: 35 },
                { label: 'Research new tool stack', tag: 'LOW', color: '#10b981', pct: 15 },
              ].map((t, i) => (
                <div className={styles.taskRow} key={i} style={{ animationDelay: `${i * 0.1}s` }}>
                  <div className={styles.taskMeta}>
                    <span className={styles.taskRank}>#{i + 1}</span>
                    <span className={styles.taskLabel}>{t.label}</span>
                    <span className={styles.taskTag} style={{ background: `${t.color}22`, color: t.color }}>
                      {t.tag}
                    </span>
                  </div>
                  <div className={styles.taskBar}>
                    <div
                      className={styles.taskBarFill}
                      style={{ width: `${t.pct}%`, background: t.color }}
                    />
                  </div>
                </div>
              ))}
            </div>
            <div className={styles.dashFooter}>
              <span>4 tasks · 2 due today</span>
              <span className={styles.dashScore}>Productivity Score: <strong>92</strong></span>
            </div>
          </div>
        </div>
      </section>

      {/* ── PROBLEM ── */}
      <section className={styles.section} id="problem">
        <div className={styles.container}>
          <div className={styles.sectionLabel} data-reveal>The Problem</div>
          <h2 className={styles.sectionHeading} data-reveal>
            You're working hard.<br />
            <span className={styles.textMuted}>You're just working on the wrong things.</span>
          </h2>
          <p className={styles.sectionSubtitle} data-reveal>
            It's not a time problem. It's a priority problem — and it's costing you clients, sleep, and momentum.
          </p>

          <div className={styles.painGrid}>
            {painPoints.map((p, i) => (
              <div className={styles.painCard} key={i} data-reveal style={{ transitionDelay: `${i * 80}ms` }}>
                <div className={styles.painIcon}>{p.icon}</div>
                <h3 className={styles.painTitle}>{p.title}</h3>
                <p className={styles.painDesc}>{p.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── SOLUTION ── */}
      <section className={styles.solutionSection} id="solution">
        <div className={styles.container}>
          <div className={styles.solutionInner}>
            <div className={styles.solutionText} data-reveal>
              <div className={styles.sectionLabel}>The Solution</div>
              <h2 className={styles.sectionHeading}>
                Your AI co-pilot for<br />
                <span className={styles.heroGradient}>ruthless focus.</span>
              </h2>
              <p className={styles.bodyText}>
                VantanceAI sits on top of your task list and thinks for you. It reads your
                deadlines, weighs the importance of every task, checks your available
                capacity — and gives you a single, clear queue to follow.
              </p>
              <p className={styles.bodyText}>
                No manual sorting. No mental overhead. Just open the app, see what's
                #1 on your list, and start.
              </p>
              <button className={styles.primaryCta} onClick={goToLogin} id="solution-cta-btn">
                Try It Free
              </button>
            </div>
            <div className={styles.solutionVisual} data-reveal>
              <div className={styles.visualCard}>
                <div className={styles.visualHeader}>
                  <div className={styles.visualDot} style={{ background: '#ef4444' }} />
                  <div className={styles.visualDot} style={{ background: '#f59e0b' }} />
                  <div className={styles.visualDot} style={{ background: '#10b981' }} />
                  <span style={{ marginLeft: 8, fontSize: 12, color: '#8F9BB3' }}>AI Ranking Engine</span>
                </div>
                <div className={styles.visualMetrics}>
                  {[
                    { label: 'Deadline Weight', val: 78, color: '#ef4444' },
                    { label: 'Task Importance', val: 91, color: '#CB6CE6' },
                    { label: 'Workload Capacity', val: 62, color: '#6366f1' },
                    { label: 'Priority Score', val: 88, color: '#10b981' },
                  ].map((m, i) => (
                    <div key={i} className={styles.metricRow}>
                      <span className={styles.metricLabel}>{m.label}</span>
                      <div className={styles.metricBar}>
                        <div
                          className={styles.metricFill}
                          style={{ width: `${m.val}%`, background: m.color }}
                        />
                      </div>
                      <span className={styles.metricVal} style={{ color: m.color }}>{m.val}%</span>
                    </div>
                  ))}
                </div>
                <div className={styles.visualResult}>
                  <span>🤖</span>
                  <span>Top task: <strong>Client proposal — Acme Corp</strong></span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section className={styles.section} id="features">
        <div className={styles.container}>
          <div className={styles.sectionLabel} data-reveal>Features → Outcomes</div>
          <h2 className={styles.sectionHeading} data-reveal>
            Built to remove friction,<br />not add more to your plate.
          </h2>

          <div className={styles.featureGrid}>
            {features.map((f, i) => (
              <div className={styles.featureCard} key={i} data-reveal style={{ transitionDelay: `${i * 80}ms` }}>
                <div className={styles.featureIcon}>{f.icon}</div>
                <h3 className={styles.featureTitle}>{f.title}</h3>
                <p className={styles.featureOutcome}>{f.outcome}</p>
                <p className={styles.featureDesc}>{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section className={styles.howSection} id="how">
        <div className={styles.container}>
          <div className={styles.sectionLabel} data-reveal>How It Works</div>
          <h2 className={styles.sectionHeading} data-reveal>
            From overwhelmed to focused<br />in three steps.
          </h2>

          <div className={styles.stepsGrid}>
            {steps.map((s, i) => (
              <div className={styles.stepCard} key={i} data-reveal style={{ transitionDelay: `${i * 100}ms` }}>
                <div className={styles.stepNum}>{s.num}</div>
                <div className={styles.stepConnector} aria-hidden="true" />
                <h3 className={styles.stepTitle}>{s.title}</h3>
                <p className={styles.stepDesc}>{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── PRODUCT PREVIEW ── */}
      <section className={styles.previewSection} id="preview">
        <div className={styles.container}>
          <div className={styles.sectionLabel} data-reveal>Product Preview</div>
          <h2 className={styles.sectionHeading} data-reveal>
            A dashboard that shows only<br />what you need — nothing more.
          </h2>

          <div className={styles.previewWrapper} data-reveal>
            <div className={styles.previewMock}>
              {/* Sidebar */}
              <div className={styles.mockSidebar}>
                <div className={styles.mockLogo}>⚡ VantanceAI</div>
                {['Dashboard', 'Tasks', 'Calendar', 'Analytics', 'Settings'].map((item, i) => (
                  <div
                    key={i}
                    className={`${styles.mockNavItem} ${i === 1 ? styles.mockNavActive : ''}`}
                  >
                    {item}
                  </div>
                ))}
              </div>
              {/* Main area */}
              <div className={styles.mockMain}>
                <div className={styles.mockTopBar}>
                  <span className={styles.mockPageTitle}>My Tasks</span>
                  <div className={styles.mockTopActions}>
                    <span className={styles.mockPill}>🔔 2 Due Today</span>
                    <span className={styles.mockPill} style={{ background: 'rgba(203,108,230,.15)', color: '#CB6CE6' }}>⚡ AI Re-sorted</span>
                  </div>
                </div>
                <div className={styles.mockCards}>
                  {[
                    { title: 'Total Tasks', val: '24', delta: '+3 today', color: '#6366f1' },
                    { title: 'Completed', val: '18', delta: '75% rate', color: '#10b981' },
                    { title: 'Overdue', val: '2', delta: '↓ from 5', color: '#ef4444' },
                    { title: 'Focus Score', val: '92', delta: 'Excellent', color: '#CB6CE6' },
                  ].map((c, i) => (
                    <div className={styles.mockStatCard} key={i}>
                      <span className={styles.mockStatLabel}>{c.title}</span>
                      <span className={styles.mockStatVal} style={{ color: c.color }}>{c.val}</span>
                      <span className={styles.mockStatDelta}>{c.delta}</span>
                    </div>
                  ))}
                </div>
                <div className={styles.mockTaskTable}>
                  {[
                    { name: 'Client proposal — Acme Corp', due: 'Today', pri: 'URGENT', done: false },
                    { name: 'Finalize invoice #042', due: 'Today', pri: 'HIGH', done: false },
                    { name: 'Team sync deck', due: 'Tomorrow', pri: 'MEDIUM', done: false },
                    { name: 'Research new stack', due: 'Fri', pri: 'LOW', done: true },
                  ].map((t, i) => (
                    <div className={`${styles.mockTaskRow} ${t.done ? styles.mockTaskDone : ''}`} key={i}>
                      <div className={`${styles.mockCheckbox} ${t.done ? styles.mockChecked : ''}`} />
                      <span className={styles.mockTaskName}>{t.name}</span>
                      <span className={styles.mockTaskDue}>{t.due}</span>
                      <span
                        className={styles.mockPriTag}
                        style={{
                          color: t.pri === 'URGENT' ? '#ef4444' : t.pri === 'HIGH' ? '#f59e0b' : t.pri === 'MEDIUM' ? '#6366f1' : '#10b981',
                          background: t.pri === 'URGENT' ? '#ef444422' : t.pri === 'HIGH' ? '#f59e0b22' : t.pri === 'MEDIUM' ? '#6366f122' : '#10b98122',
                        }}
                      >
                        {t.pri}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ── */}
      <section className={styles.section} id="testimonials">
        <div className={styles.container}>
          <div className={styles.sectionLabel} data-reveal>Social Proof</div>
          <h2 className={styles.sectionHeading} data-reveal>
            Real results.<br />Real freelancers.
          </h2>

          <div className={styles.testimonialsWrap} data-reveal>
            {testimonials.map((t, i) => (
              <div
                key={i}
                className={`${styles.testimonialCard} ${i === activeTestimonial ? styles.testimonialActive : ''}`}
                onClick={() => setActiveTestimonial(i)}
              >
                <div className={styles.testimonialQuote}>"</div>
                <p className={styles.testimonialText}>{t.quote}</p>
                <div className={styles.testimonialAuthor}>
                  <div className={styles.testimonialAvatar}>{t.avatar}</div>
                  <div>
                    <div className={styles.testimonialName}>{t.name}</div>
                    <div className={styles.testimonialRole}>{t.role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className={styles.testimonialDots} data-reveal>
            {testimonials.map((_, i) => (
              <button
                key={i}
                className={`${styles.dot} ${i === activeTestimonial ? styles.dotActive : ''}`}
                onClick={() => setActiveTestimonial(i)}
                aria-label={`Testimonial ${i + 1}`}
              />
            ))}
          </div>
        </div>
      </section>

      {/* ── FINAL CTA ── */}
      <section className={styles.ctaSection}>
        <div className={styles.ctaBg} aria-hidden="true">
          <div className={styles.ctaBlob} />
        </div>
        <div className={styles.container}>
          <div className={styles.ctaInner} data-reveal>
            <h2 className={styles.ctaHeading}>
              Your next deadline won't wait.<br />
              <span className={styles.heroGradient}>Neither should you.</span>
            </h2>
            <p className={styles.ctaSubtitle}>
              Join 2,400+ freelancers who stopped drowning in tasks and started shipping consistently.
            </p>
            <button
              className={styles.ctaPrimaryBtn}
              onClick={goToLogin}
              id="final-cta-btn"
            >
              Create Your Free Account →
            </button>
            <p className={styles.ctaNote}>No credit card. No commitment. Cancel anytime.</p>
          </div>
        </div>
      </section>

      {/* ── FOOTER ── */}
      <footer className={styles.footer}>
        <div className={styles.container}>
          <div className={styles.footerInner}>
            <div className={styles.footerBrand}>
              <div className={styles.logo}>
                <span className={styles.logoIcon}>⚡</span>
                <span className={styles.logoText}>VantanceAI</span>
              </div>
              <p className={styles.footerTagline}>
                AI-powered focus for freelancers and small teams.
              </p>
            </div>

            <div className={styles.footerLinks}>
              <div className={styles.footerCol}>
                <div className={styles.footerColTitle}>Product</div>
                <a href="#features" className={styles.footerLink}>Features</a>
                <a href="#how" className={styles.footerLink}>How It Works</a>
                <a href="#testimonials" className={styles.footerLink}>Reviews</a>
              </div>

              <div className={styles.footerCol}>
                <div className={styles.footerColTitle}>Company</div>
                <a href="mailto:hello@vantanceai.com" className={styles.footerLink}>Contact Us</a>
                <a
                  href="https://github.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={styles.footerLink}
                >
                  GitHub
                </a>
                <a
                  href="https://linkedin.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={styles.footerLink}
                >
                  LinkedIn
                </a>
              </div>

              <div className={styles.footerCol}>
                <div className={styles.footerColTitle}>Account</div>
                <button className={styles.footerLink} onClick={goToLogin} id="footer-login-btn">
                  Sign In
                </button>
                <button className={styles.footerLink} onClick={goToLogin} id="footer-register-btn">
                  Register
                </button>
              </div>
            </div>
          </div>

          <div className={styles.footerBottom}>
            <span>© 2026 VantanceAI. All rights reserved.</span>
            <span>Built with ⚡ for focused people.</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
